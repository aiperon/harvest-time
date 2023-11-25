# frozen_string_literal: true

require_relative '../formatter_test'

class Formatter
  class Plain < Minitest::Test
    def setup
      @formatter = HarvestTime::Formatter::Plain.new
    end

    def test_generate_output_empty
      assert_output("#{@formatter.header_row}\n") { @formatter.generate_output([]) }
    end

    def test_generate_output
      data = [{ 'spent_date' => '2020-01-01', 'hours' => 1.5, 'billable_rate' => 100,
                'task' => { 'name' => 'TaskName1' } }]
      out, = capture_io { @formatter.generate_output(data) }
      lines = out.split("\n")
      assert_match 'Date', lines[0]
      assert_match Regexp.new(%w[2020-01-01 TaskName1 150].join('.*')), lines[1]
    end
  end
end
