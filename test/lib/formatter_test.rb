# frozen_string_literal: true

require 'test_helper'

class FormatterTest < Minitest::Test
  def test_select
    klass = HarvestTime::Formatter

    assert_instance_of klass::Plain, klass.select(output: '1')
    assert_instance_of klass::Plain, klass.select(output: '1.css')
    assert_instance_of klass::Plain, klass.select(output: nil)
    assert_instance_of klass::JSON,  klass.select(output: '1.json')
    assert_instance_of klass::Table, klass.select(output: '1.csv')
  end

  def test_validate_out_path
    refute HarvestTime::Formatter.validate_output(nil)
    assert HarvestTime::Formatter.validate_output('1')
    assert HarvestTime::Formatter.validate_output('1.csv')
    assert_raises(HarvestTime::InvalidPathError) { HarvestTime::Formatter.validate_output('/1/2.csv') }
  end
end
