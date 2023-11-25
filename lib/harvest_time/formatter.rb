# frozen_string_literal: true

require_relative 'formatter/base'
require_relative 'formatter/table'
require_relative 'formatter/json'
require_relative 'formatter/plain'

module HarvestTime
  # Formatters Fabric
  class Formatter
    KLASS_BY_EXTENSION = {
      'csv' => Formatter::Table,
      'json' => Formatter::JSON,
      nil => Formatter::Plain
    }.freeze

    HEADERS = {
      'spent_date' => 'Date',
      'hours' => 'Hours',
      'project.id' => 'Project ID',
      'project.name' => 'Project',
      'task.id' => 'Task ID',
      'task.name' => 'Task',
      'started_time' => 'Started At',
      'ended_time' => 'Ended At',
      'billable_rate' => 'Billable Rate',
      'billable_amount' => 'Billable Amount',
      'notes' => 'Notes'
    }.freeze

    # TODO: make it configurable
    OUT_FIELDS = %w[spent_date task.name notes billable_amount hours started_time ended_time].freeze

    def self.select(output: nil)
      validate_output(output)

      ext = output&.split('.')&.last
      klass = KLASS_BY_EXTENSION[ext] || KLASS_BY_EXTENSION[nil]
      klass.new(output: output)
    end

    def self.validate_output(output)
      return false unless output

      dir_path = File.dirname(File.expand_path(output))
      return true if File.exist?(dir_path)

      raise InvalidPathError, "Path doesn't exist: #{output}"
    end

  end
end
