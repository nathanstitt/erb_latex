module ErbLatex

    module File

        # simualar to File.read, except:
        #   * Will search in_directory for file if given, otherwise expects file to be an absolute path
        #   * appends ErbLatex.config.file_extension to the file if it's not found as-is.
        def self.read(requested_file, in_directory = nil)
            file = requested_file
            if in_directory
                file = Pathname.new(in_directory.to_s).join(file)
            end
            if file.to_s !~ /#{ErbLatex.config.file_extension}$/ && !file.exist?
                file = Pathname.new(file.to_s + ErbLatex.config.file_extension)
            end
            unless file.exist?
                msg = "Unable to read from #{requested_file}."
                msg << " Also tried extension #{file}" if file != requested_file
                raise LatexError.new(msg)
            end
            file.read
        end

        def self.evaluate(file, context_binding, directory = nil)
            ::ERB.new( self.read(file, directory), 0, '-' ).result( context_binding )
        end

    end

end
