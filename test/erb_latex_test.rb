# -*- coding: utf-8 -*-
require 'helper'

class ErbLatexTest < MiniTest::Test


    def test_document
        tmpl = ErbLatex::Template.new( document(:valid) )
        tmpl.to_file tmp_output_file
        assert_match "This is a very simple file", text_output
    end

    def test_errors
        tmpl = ErbLatex::Template.new( document(:with_error) )
        assert_raises(ErbLatex::LatexError) do
            tmpl.to_stringio
        end
    end

    def test_layout
        tmpl = ErbLatex::Template.new( document(:body),
                                       :layout => document(:layout),
                                       :data   => { :sentence=>"hello, this is doge" }
                                     )
        tmpl.to_file tmp_output_file
        assert_match "hello, this is doge", text_output
    end

    def test_multiple_runs
        tmpl = ErbLatex::Template.new( document(:multi_page) )
        tmpl.to_file tmp_output_file
        assert_equal 2, tmpl.pass_count
        text = text_output
        assert_match "Page 1 of 3", text
        assert_match "Page 2 of 3", text
        assert_match "Page 3 of 3", text
    end

    def test_partials
        tmpl = ErbLatex::Template.new( document(:with_partial) )
        tmpl.to_file tmp_output_file
        assert_match "a test ’ of a partial", text_output
    end

    def test_path_with_extension
        tmpl = ErbLatex::Template.new( document('with_partial.tex.erb') )
        tmpl.to_file tmp_output_file
        assert_match "a test ’ of a partial", text_output
    end

    def test_custom_context
        tmpl = ErbLatex::Template.new(
            document('custom_context.tex.erb'),
            context: CustomContext
        )
        tmpl.to_file tmp_output_file
        assert_match "custom helper method", text_output
    end
end
