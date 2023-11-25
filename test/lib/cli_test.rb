# frozen_string_literal: true

require 'test_helper'

class CLITest < Minitest::Test
  def init(*args)
    @cli = HarvestTime::CLI.new(args)
    @cli.fill_options!
    @options = @cli.options
  end

  def test_exit_on_help
    init('-h', '-v')
  rescue SystemExit => e
    assert_equal 42, e.status
  end

  def test_rescue_invalid_option
    init('-x321', '-v')
    assert_equal false, @options[:verbose]
  end

  def test_parse_dates
    init('--from', '2020', '--to', '2021-01-01')
    assert_equal [nil, '2021-01-01'], @options.fetch_values(:from, :to)

    init('--from', '2020-01-01', '--to', '2021-01-23')
    assert_equal %w[2020-01-01 2021-01-23], @options.fetch_values(:from, :to)

    init('--from', '2023-06-01', '--prev')
    Timecop.freeze(Date.parse('2023-10-01')) do
      assert_equal %w[2023-10-01 2023-10-31], @options.fetch_values(:from, :to)
    end
  end

  def test_run
    init
    assert_respond_to(@cli, :run)
  end

  def test_params
    init('--project', 'Project', '--tasks', 'Task1,Task2')
    assert_equal({ project: 'Project', tasks: 'Task1,Task2' }, @options[:params])

    init('--project', 'Project2')
    assert_equal({ project: 'Project2', tasks: nil }, @options[:params])
  end

  def test_empty_dates
    current_month = HarvestTime::DateString.current_month_period

    init
    assert_equal(current_month, @options.fetch_values(:from, :to))

    init('--from', '2021-01-10', '--to', 'xyz')
    assert_equal(['2021-01-10', nil], @options.fetch_values(:from, :to))

    init('--from', '2020', '--to', '2021-01-32')
    assert_equal(current_month, @options.fetch_values(:from, :to))
  end

  def test_previous_month
    prev_month = HarvestTime::DateString.prev_month_period

    init('--prev')
    assert_equal(prev_month, @options.fetch_values(:from, :to))

    init('--from', '2022-01-01', '--prev')
    assert_equal(prev_month, @options.fetch_values(:from, :to))
  end
end
