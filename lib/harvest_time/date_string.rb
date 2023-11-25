# frozen_string_literal: true

require 'date'

module HarvestTime
  # Utilities to work with dates
  class DateString
    class << self
      def month_period_on_date(date)
        [Date.new(date.year, date.month, 1).to_s, Date.new(date.year, date.month, -1).to_s]
      end

      def prev_month_period
        month_period_on_date(Date.today.prev_month)
      end

      def current_month_period
        month_period_on_date(Date.today)
      end

      def to_param(str)
        return nil if str.nil?

        error_class = Date.constants.include?(:Error) ? Date::Error : ArgumentError
        begin
          Date.strptime(str).to_s # ISO 8601
        rescue error_class
          nil
        end
      end
    end
  end
end