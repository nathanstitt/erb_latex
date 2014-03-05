module ErbLatex

    # An ErbLatex::StringIO extends Ruby's StringIO
    # with a path and file name
    # This allows it to be used in situations where a
    # File is expected
    class StringIO < ::StringIO

        # @attribute [rw] filepath
        #   @return [String] complete *virtual* path for the data
        attr_accessor :filepath

        def initialize( name='' )
            @filepath = name
            super('')
            self.set_encoding( Encoding.find("UTF-8") )
        end

        # define original_filename for clients that
        # depend on it, i.e. carrierwave
        def original_filename
            File.basename(filepath)
        end

        # reset filepath
        # @param name [String] new value for filepath
        # @return self
        def rename( name )
            @filepath = name
            self
        end
    end

end
