notification :growl

guard :minitest, :all_on_start => true do
    watch(%r{^test/test_helper\.rb}) { 'test' }

    watch(%r{^test/.+_test\.rb})
    watch(%r{^test/fixtures/(.+)s\.tex})   { |m| "test/erb_latex_test.rb" }

    watch(%r{^lib/erb_latex/(.+)\.rb})     { |m| "test/erb_latex_test.rb" }
end
