# frozen_string_literal: true

require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.libs << 'test'
  t.warning = false
  t.test_globs = %w[test/**/*_test.rb]
end

task default: :test
