require "bundler/gem_tasks"

require 'bundler/setup'
require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'
require 'guard'

Rake::TestTask.new do |t|
    t.libs << 'test'
    t.pattern = "test/*_test.rb"
end

YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    t.options = [
      "--title=ERB LaTeX",
      "--markup=markdown",
      "--template-path=yard_ext/templates",
      "--readme=README.md"
    ]
end

desc "Deploy docs to web server"
task :docs do
    Rake::Task["yard"].invoke
    system( "rsync", "doc/", "-avz", "--delete", "nathan.stitt.org:~/docs/erb-latex")
end
