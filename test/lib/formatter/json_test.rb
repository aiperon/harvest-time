# frozen_string_literal: true

require_relative '../formatter_test'

class Formatter
  class JSON < Minitest::Test
    def setup
      @filename = '1.json'
      @formatter = HarvestTime::Formatter::JSON.new(output: @filename)
    end

    def teardown
      File.delete(@filename) if File.exist?(@filename)
    end

    def test_generate_output
      data = [{ 'spent_date' => '2020-01-01', 'hours' => 1.5, 'billable_rate' => 100,
                'task' => { 'name' => 'TaskName1' } }]
      expected = [
        { 'spent_date' => '2020-01-01', 'task.name' => 'TaskName1', 'notes' => nil,
          'billable_amount' => 150.0, 'hours' => 1.5,
          'started_time' => nil, 'ended_time' => nil }
      ]
      @formatter.generate_output(data)
      assert File.exist?(@filename)
      assert_equal expected, ::JSON.parse(File.read(@filename))
    end
  end
end
