# frozen_string_literal: true

require 'test_helper'

class DateStringTest < Minitest::Test
  def setup
    @klass = HarvestTime::DateString
  end

  def test_month_period_on_date
    assert_equal %w[2020-01-01 2020-01-31], @klass.month_period_on_date(Date.parse('2020-01-16'))
    assert_equal %w[2020-02-01 2020-02-29], @klass.month_period_on_date(Date.parse('2020-02-16'))
  end

  def test_prev_month_period
    Timecop.freeze(Date.new(2022, 1, 16)) do
      assert_equal %w[2021-12-01 2021-12-31], @klass.prev_month_period
    end

    Timecop.freeze(Date.parse('2022-03-31')) do
      assert_equal %w[2022-02-01 2022-02-28], @klass.prev_month_period
    end
  end

  def test_current_month_period
    Timecop.freeze(Date.parse('2022-03-15')) do
      assert_equal %w[2022-03-01 2022-03-31], @klass.current_month_period
    end
  end

  def test_to_param
    assert_equal '2022-01-01', @klass.to_param('2022-01-01')
    assert_nil @klass.to_param('20221233')
    assert_nil @klass.to_param(nil)
  end
end
