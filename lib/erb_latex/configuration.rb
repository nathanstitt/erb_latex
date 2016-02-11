module ErbLatex
    class << self
        attr_reader :config
    end


    def self.configure
        yield(@config)
    end

    class Configuration
        attr_accessor :file_extension
        attr_accessor :xelatex_path
        attr_accessor :verbose_logs

        def initialize
            @verbose_logs   = false
            @file_extension = '.tex.erb'
            @xelatex_path   = 'xelatex'
        end
    end

    # Initialize configuration with defaults
    @config = Configuration.new
end
