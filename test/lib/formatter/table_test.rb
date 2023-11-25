# frozen_string_literal: true

require_relative '../formatter_test'

class Formatter
  class Table < Minitest::Test
    def setup
      @filename = '1.csv'
      @formatter = HarvestTime::Formatter::Table.new(output: @filename)
    end

    def teardown
      File.delete(@filename) if File.exist?(@filename)
    end

    def test_generate_output
      data = [{ 'spent_date' => '2020-01-01', 'hours' => 1.5, 'billable_rate' => 100,
                'task' => { 'name' => 'TaskName1' } }]
      expected = [
        ['Date', 'Task', 'Notes', 'Billable Amount', 'Hours', 'Started At', 'Ended At'],
        ['2020-01-01', 'TaskName1', nil, '150,0', '1,5', nil, nil]
      ]
      @formatter.generate_output(data)
      assert File.exist?(@filename)
      assert_equal expected, CSV.read(@filename)
    end
  end
end
