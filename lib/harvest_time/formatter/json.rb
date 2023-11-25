# frozen_string_literal: true

require 'json'

module HarvestTime
  class Formatter
    # Formatter for JSON output
    class JSON < Base
      def generate_output(data)
        json = data.map do |item|
          fill_billable_amount(item)
          new_item = {}
          OUT_FIELDS.each { |field| new_item[field] = get_value(item, field) }
          new_item
        end

        File.open(@output, 'w') do |file|
          file.write(::JSON.dump(json))
        end
      end
    end
  end
end
