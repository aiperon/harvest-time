# frozen_string_literal: true

require 'optparse'

module HarvestTime
  # Command line interface for the HarvestTime module
  class CLI < OptionParser
    attr_reader :args, :options

    def initialize(argv = [])
      @args = argv
      @options = { verbose: false, output: nil, from: nil, to: nil, prev: false }
      super('Usage: harvest_time [options]')

      separator ''
      separator 'Export time entries from Harvest account'
      separator ''

      list_options
    end

    def list_options
      on('-h', '--help', 'Show this message')
      on('-v', '--verbose', 'Verbose output')
      on('-o', '--output FILENAME', 'Output file name (format is determined by extension)')

      on('-p', '--project PROJECT_NAME', 'Tracked for the project')
      on('--tasks TASK_NAME(S)', 'Tracked for the task(s) (separated by commas)')
      on('--from YYYY-MM-DD', 'From date')
      on('--to YYYY-MM-DD', 'To date')
      on('--prev', 'Previous month (overrides --from and --to)')
    end

    def run
      fill_options!

      begin
        HarvestTime::Exporter.new(**options).run
      rescue SocketError, Net::OpenTimeout => e
        capture_error e
      rescue StandardError => e
        capture_error e
      end
    end

    def fill_options!
      begin
        parse!(@args, into: @options)
      rescue OptionParser::InvalidOption => e
        puts e.message
      end

      if @options[:help]
        puts self
        exit 42
      end

      post_format_options
    end

    def post_format_options
      @options[:from], @options[:to] = prepare_dates
      @options[:params] = { project: @options.delete(:project), tasks: @options.delete(:tasks) }
    end

    def prepare_dates
      if @options.delete(:prev)
        DateString.prev_month_period
      else
        from = DateString.to_param(@options[:from])
        to = DateString.to_param(@options[:to])
        from, to = DateString.current_month_period if from.nil? && to.nil?
        [from, to]
      end
    end

    private

    def capture_error(error)
      puts [
        'Try again with verbose mode (-v) for more details',
        "FATAL(#{error.class.name}): #{error.message}",
        error.backtrace.join("\n")
      ].join("\n")
      exit 500
    end
  end
end
