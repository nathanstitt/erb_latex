require 'guard'
require 'guard/plugin'
require 'erb_latex'
require 'erb_latex/guard_runner'

module Guard


    # The ErbLatex guard that gets notifications about the following
    # Guard events: `start`, `run_all` and `run_on_modifications`.
    class ErbLatex < Plugin

        DEFAULT_OPTIONS = {
            :layout       => false,
            :data         => {},
            :all_on_start => true,
            :hide_success => false
        }

        # Initialize Guard::ErbLates
        #
        # @param [Hash] options the options for the Guard
        # @option options [String] :layout, the layout to apply to latex files
        # @option options [String] :data, for use during the ERB processing
        # @option options [Boolean] :all_on_start process all latex files on start
        # @option options [Boolean] :hide_success hide success message notification, unless the previous run failed
        def initialize( options = {} )
            super( DEFAULT_OPTIONS.merge(options) )
        end

        # Gets called once when Guard starts.
        #
        # @raise [:task_has_failed] when stop has failed
        #
        def start
            run_all if options[:all_on_start]
        end

        # Gets called when all files should be regenerated.
        #
        # @raise [:task_has_failed] when stop has failed
        #
        def run_all
            run_on_modifications( Watcher.match_files(self, Dir.glob('**{,/*/**}/*.{tex,erb.tex,tex.erb}')) )
        end

        # Gets called when watched paths and files have changes.
        #
        # @param [Array<String>] paths the changed paths and files
        # @raise [:task_has_failed] when stop has failed
        #
        def run_on_modifications(paths)
            throw :task_has_failed unless ::ErbLatex::GuardRunner.run( paths, watchers, options )
        end

    end

end
