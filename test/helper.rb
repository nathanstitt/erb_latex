require 'rubygems'
require 'bundler'
require 'minitest'


require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'erb_latex'

class CustomContext < ErbLatex::Context
    def output_test_string
        'A string from custom helper method'
    end
end

class MiniTest::Test

    def document( name )
        File.expand_path(File.join(File.dirname(__FILE__), "fixtures/#{name}"))
    end

    def tmp_output_file
        File.expand_path( File.join( File.dirname(__FILE__), "tmp/output.pdf") )
    end


    def text_output
        `pdftotext #{tmp_output_file} -`
    end

end
