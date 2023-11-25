# frozen_string_literal: true

require 'csv'

module HarvestTime
  class Formatter
    # Formatter for CSV output
    class Table < Base
      def generate_output(data)
        CSV.open(@output, 'w') do |csv|
          csv << HEADERS.fetch_values(*OUT_FIELDS)
          data.each do |item|
            fill_billable_amount(item)
            csv << OUT_FIELDS.map { |field| get_value(item, field, replace_dot: true) }
          end
        end
      end
    end
  end
end
