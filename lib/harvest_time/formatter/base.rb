# frozen_string_literal: true

module HarvestTime
  class Formatter
    # Base class for output formatters
    class Base
      def initialize(output: nil)
        @output = output
      end

      # Harvest do not return billable_amount in API, so we need to calculate it for each item
      def fill_billable_amount(item)
        return unless item['billable_rate'] || item['hours']

        item['billable_amount'] = (item['hours'] * item['billable_rate']).round(2)
      end

      def get_value(item, field, replace_dot: false)
        value = item.dig(*field.split('.'))
        value = value.to_s.gsub('.', ',') if replace_dot && value.is_a?(Float)
        value
      end

      def generate_output(data)
        raise NotImplementedError
      end
    end
  end
end
