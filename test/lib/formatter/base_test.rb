# frozen_string_literal: true

require_relative '../formatter_test'

class FormatterTest
  class BaseTest < Minitest::Test
    def test_fill_billable_amount
      formatter = HarvestTime::Formatter::Base.new

      item = {}
      formatter.fill_billable_amount(item)
      assert_nil item['billable_amount']

      item = { 'hours' => 2, 'billable_rate' => 10.333 }
      formatter.fill_billable_amount(item)
      assert_equal 20.67, item['billable_amount']
    end

    def test_get_value
      formatter = HarvestTime::Formatter::Base.new

      assert_nil formatter.get_value({ 'a' => '1' }, 'b.c')

      assert_equal '1', formatter.get_value({ 'a' => '1' }, 'a')
      assert_equal '2', formatter.get_value({ 'a' => { 'b' => '2' } }, 'a.b')

      assert_equal 2.5, formatter.get_value({ 'a' => 2.5 }, 'a', replace_dot: false)
      assert_equal '2,5', formatter.get_value({ 'a' => 2.5 }, 'a', replace_dot: true)
    end
  end
end
