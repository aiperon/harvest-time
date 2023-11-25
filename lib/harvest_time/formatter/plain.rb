# frozen_string_literal: true

module HarvestTime
  class Formatter
    # Formatter for output in STDOUT
    class Plain < Base
      def generate_output(data)
        puts header_row

        data.each do |item|
          fill_billable_amount(item)
          puts OUT_FIELDS.map { |field| get_value(item, field) || '-' }.join("\t\t")
        end
      end

      def header_row
        # header titles with ? if not defined title
        HEADERS.fetch_values(*OUT_FIELDS).map { |v| v || '?' }.join("\t\t")
      end
    end
  end
end
