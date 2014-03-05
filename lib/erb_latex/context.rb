module ErbLatex

    # Is the execution context for ERB evaluation
    #
    class Context

        # List of characters that need to be escaped
        # and their escaped values
        ESCAPE = {
            "#"=>"\\#",
            "$"=>"\\$",
            "%"=>"\\%",
            "&"=>"\\&",
            "~"=>"\\~{}",
            "_"=>"\\_",
            "^"=>"\\^{}",
            "\\"=>"\\textbackslash{}",
            "{"=>"\\{",
            "}"=>"\\}"
        }

        # create new Context
        # @param directory [String] directory to use as a base for finding partials
        # @param data [Hash]
        def initialize( directory, data )
            @directory = directory
            @data      = data
            data.each{ |k,v| instance_variable_set( '@'+k.to_s, v ) }
        end

        # include another latex file into the current template
        def partial( template, data={} )
            view_file = @directory.join( template )
            if view_file.exist?
                context = Context.new( @directory, data )
                ERB.new( view_file.read, 0, '-' ).result(  context.getBinding )
            else
                "missing partial: #{template}"
            end
        end

        # convert newline characters into latex '\\newline'
        def break_lines( txt )
            q(txt.to_s).gsub("\n",'\\newline ')
        end

        # return a reference to the instance's scope or 'binding'
        def getBinding
            return binding()
        end

        # escape using latex escaping rules
        # @param text string to escape
        # @return [String] text after {ESCAPE} characters are replaced
        def q(text)
            text.to_s.gsub(  /([\^\%~\\\\#\$%&_\{\}])/ ) { |s| ESCAPE[s] }
        end

    end

end
