require "tmpdir"
require "open3"
require "erb"
require 'pathname'
require 'fileutils'

module ErbLatex

    # A template is an latex file that contains embedded ERB code
    # It can optionally have a layout be rendered to either a file
    # or StringIO instance
    # @example for a hypothetical Rails controller
    #     tmpl = ErbLatex::Template.new( 'article.tex',
    #        :layout => 'layout.tex'
    #        :data   => { :sentence=>"hello, this is doge" }
    #     )
    #     render :pdf => tmpl.to_stringio.read
    #
    class Template

        # @attribute [r] log
        #   @return [String] the log from the last xelatex run
        # @attribute [r] pass_count
        #   @return [Fixnum] how many passes it took to compile the tex into a PDF
        attr_reader   :log,    :pass_count
        # @attribute [rw] layout
        #   @return [String] path to a file to use for layout
        # @attribute [rw] packages_path
        #   @return [String] path to a directory to search for packages
        # @attribute [rw] partials_path
        #   @return [String] path to a directory to search for partials to include
        attr_accessor :layout, :packages_path, :partials_path

        # create a new Template
        # @param view_file [String] path to the latex template
        # @option options [String] :layout path to a latex template that calls yield
        # @option options [Hash]   :data an instance variable will be created in the view for each key/value pair
        # @option context [Class]  : a class that will be instantiated to provide helper methods to ERB templates.  Defaults to ErbLatex:Context

        def initialize( view_file, options={} )
            @data   = options[:data] || {}
            @layout = options[:layout]
            @context = options[:context] || ErbLatex::Context
            @packages_path = options[:packages_path]
            @partials_path = options[:partials_path]
            @view   = Pathname.new( view_file )
            @log  = ''
        end

        # Sets the data to be used for the template
        # @param hash [Hash] data to set for the template
        # An instance variable will be created for the template
        # for each key in the hash with it's value set accordingly
        def data=( hash )
            @data  = hash
        end

        # @return [String] the suggested filename for this template.
        # It removes the extension from the name and replaces it with '.pdf'
        def suggested_filename
            @view.basename.to_s.gsub(/\..*$/, '.pdf')
        end

        # Save the PDF to the file
        # @param file [String,IO] if file is a String, the PDF is moved to the path indicated (most efficient).
        #        Otherwise, file is considered an instance of IO, and write is called on it with the PDF contents
        # @return [String,IO] the file
        def to_file( file = suggested_filename )
            execute do | contents |
                if file.is_a?(String)
                    FileUtils.mv contents, file
                else
                    file.write contents.read
                    file.rewind
                end
            end
            file
        end

        # @return [StringIO] containing the the PDF
        def to_stringio
            to_file( ::ErbLatex::StringIO.new(suggested_filename) )
        end

        # Compile the Latex template into a PDF file
        # @yield [Pathname] complete path to the PDF file
        # @raise [LatexError] if the xelatex process does not complete successfully
        def execute
            latex = compile_latex
            Dir.mktmpdir do | dir |
                @pass_count = 0
                @log        = ''
                success     = false
                while log_suggests_rerunning? && @pass_count < 5
                    @pass_count += 1
                    success = execute_xelatex(latex,dir)
                end
                pdf_file = Pathname.new(dir).join( "output.pdf" )
                if success && pdf_file.exist?
                    yield pdf_file
                else
                    errors = @log.scan(/\*\!\s(.*?)\n\s*\n/m).map{|e| e.first.gsub(/\n/,'') }.join("; ")
                    STDERR.puts @log, errors if ErbLatex.config.verbose_logs
                    raise LatexError.new( errors.empty? ? "xelatex compile error" : errors, @log )
                end
            end
        end

        # @return [Pathname] layout file
        def layout_file
            Pathname.new( layout )
        end

        # Runs the ERB pre-process on the latex file
        # @return [String] latex with ERB substitutions performed
        # @raise [LatexError] if the xelatex process does not complete successfully
        def compile_latex
            begin
                context = @context.new( @partials_path || @view.dirname, @data )
                content = ErbLatex::File.evaluate(@view, context.getBinding)
                if layout
                    ErbLatex::File.evaluate(layout_file, context.getBinding{ content })
                else
                    content
                end
            rescue LocalJumpError=>e
                raise LatexError.new( "ERB compile raised #{e.class} on #{@view}", e.backtrace )
            end
        end

        private

        # @return [Boolean] True if the log is empty(not ran yet), or contains the string "Rerun"
        def log_suggests_rerunning?
            @log.empty? || !! ( @log =~ /Rerun/ )
        end

        # Execute xelatex on the file.
        # @param latex [String] contents of the template after running ERB on it
        # @param dir   [String] path to the temporary working directory
        def execute_xelatex( latex, dir )
            success = false
            @log    = ''

            if @packages_path
                ENV['TEXINPUTS'] = "#{@packages_path}:"
            end
            Open3.popen2e( ErbLatex.config.xelatex_path,
              "--no-shell-escape", "-shell-restricted",
              "-jobname=output",   "-output-directory=#{dir}",
            ) do |stdin, output, wait_thr|
                stdin.write latex
                stdin.close
                @log    = output.read.strip
                success = ( 0 == wait_thr.value )
            end
            success
        end

    end

end
