module ErbLatex

    # Encapsolates an error that occurs while processing a latex template
    class LatexError < RuntimeError

        # @attribute [r] log
        #   @return the log from the xelatex run
        attr_reader :log

        def initialize( msg, log )
            super(msg)
            @log = log
        end

    end

end
