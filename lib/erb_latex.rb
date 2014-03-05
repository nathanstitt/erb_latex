require "erb_latex/version"
require "erb_latex/errors"
require "erb_latex/context"
require "erb_latex/stringio"
require "erb_latex/template"
module ErbLatex



    def self.xelatex_binary
        defined?(@@xelatex_binary) ? @@xelatex_binary  : "xelatex"
    end

    def self.xelatex_binary=(bin)
        @@xelatex_binary = bin
    end
end
