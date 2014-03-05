require 'erb_latex'

module ErbLatex
    module GuardRunner
        class << self

            attr_accessor :last_run_failed

            # The ErbLatex runner handles the ErbLatex compilation,
            # creates the output pdf file, writes the result
            # to the console and triggers optional system notifications.
            #
            # @param [Array<String>] files the spec files or directories
            # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
            # @param [Hash] options the options for the execution
            # @option options [String] :layout, the layout to apply to latex files
            # @option options [String] :data, for use during the ERB processing
            # @return [Array<Array<String>, Boolean>] the result for the compilation run
            #
            def run(files, watchers, options = { })
                ::Guard::UI.info('Compiling ' + files.join(', '), :reset=>true )
                changed_files, errors = compile_files(files, watchers, options)
                notify_result(changed_files, errors, options)
                return errors.empty?
            end


            private

            # Compiles all ErbLatex files and writes the PDF files.
            #
            # @param [Array<String>] files the files to compile
            # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
            # @param [Hash] options the options for the execution
            # @return [Array<Array<String>, Array<String>] the result for the compilation run
            #
            def compile_files(files, watchers, options)
                errors        = []
                changed_files = []

                files.each do |file|
                    begin
                        pdf = ErbLatex::Template.new( file, options ).to_file
                        changed_files << pdf
                    rescue LatexError => e
                        error_message = file + ': ' + e.message.to_s
                        errors << error_message
                        ::Guard::UI.error(color(error_message, ';31'), options)
                    end
                end
                [changed_files.flatten.compact, errors]
            end

            # Writes console and system notifications about the result of the compilation.
            #
            # @param [Array<String>] changed_files the changed JavaScript files
            # @param [Array<String>] errors the error messages
            # @param [Hash] options the options for the execution
            # @option options [Boolean] :hide_success hide success message notification
            # @option options [Boolean] :noop do not generate an output file
            #
            def notify_result(changed_files, errors, options = { })
                if !errors.empty?
                    self.last_run_failed = true
                    ::Guard::Notifier.notify(errors.join("\n"), :title => 'ErbLatex results', :image => :failed, :priority => 2)
                elsif !options[:hide_success] || last_run_failed
                    self.last_run_failed = false
                    message = "Successfully #{ options[:noop] ? 'verified' : 'generated' } #{ changed_files.join(', ') }"
                    ::Guard::UI.info(color( "#{Time.now.strftime('%r')} #{message}", ';32'), options)
                    ::Guard::Notifier.notify(message, :title => 'ErbLatex results')
                end
            end

            # Print a info message to the console.
            # @param [String] text the text to colorize
            # @param [String] color_code the color code
            def color(text, color_code)
                ::Guard::UI.send(:color_enabled?) ? "\e[0#{ color_code }m#{ text }\e[0m" : text
            end

        end
    end
end
