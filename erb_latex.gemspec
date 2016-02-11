# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'erb_latex/version'

Gem::Specification.new do |spec|
    spec.name          = "erb_latex"
    spec.version       = ErbLatex::VERSION
    spec.authors       = ["Nathan Stitt"]
    spec.email         = ["nathan@stitt.org"]
    spec.summary       = %q{Applies ERB template processing to a Latex file and compiles it to a PDF}
    spec.description   = %q{Applies ERB template processing to a Latex file and compiles it to a PDF.  Supports layouts, partials, and string escaping. Also supplies a Guard task to watch for modifications and auto-building files.}
    spec.homepage      = "https://github.com/nathanstitt/erb_latex"
    spec.license       = "MIT"

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ["lib"]

    spec.add_development_dependency "rake",    "~> 10.5"
    spec.add_development_dependency "bundler", "~> 1.10"
    spec.add_development_dependency "yard",    "~> 0.8"
    spec.add_development_dependency "guard",   "~> 2.13"
    spec.add_development_dependency "guard-minitest", "~> 2.4"
end
