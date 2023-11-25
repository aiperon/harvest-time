# frozen_string_literal: true

module HarvestTime
  # Export time entries from Harvest account
  class Exporter
    attr_reader :client

    def initialize(from:, to:, output:, verbose:, params: { tasks: nil, project: nil })
      @from = from
      @to = to
      @debug = verbose
      @params = params || {}
      @params[:tasks] = @params[:tasks]&.split(',') if @params.key?(:tasks)
      @client = ApiClient.new(debug: verbose)
      @formatter = Formatter.select(output: output)
    end

    def run
      project_id, task_ids = export_filter_ids
      time_entries = export_time_entries(project_id: project_id, task_ids: task_ids)
      @formatter.generate_output(time_entries)

      # additional check to avoid items iteration if it's not a verbose mode
      return unless @debug

      debug_log "Time entries count: #{time_entries&.count}. Hours spent: #{time_entries.sum { |x| x['hours'] }}."
    end

    def export_time_entries(project_id: nil, task_ids: nil)
      @client.run(action: ApiClient::TIME_ENTRIES,
                  query: {
                    from: @from, to: @to, project_id: project_id,
                    'task_id[]' => task_ids
                  })
    end

    def export_filter_ids
      return nil if @params.empty?

      [
        export_item_ids(ApiClient::PROJECTS, :project),
        export_item_ids(ApiClient::TASKS, :tasks)
      ]
    end

    def export_item_ids(api_action, param_value)
      param_value = @params[param_value]
      return nil if param_value.nil?

      items = @client.run(action: api_action)
      return nil if items.nil?

      result = self.class.find_ids(items, param_value)

      # additional check to avoid items iteration if it's not a verbose mode
      if @debug
        debug_log "#{api_action} names: [#{items.map { |x| x['name'] }.join(',')}]"
        debug_log "#{param_value} id: #{result}"
      end

      result
    end

    def self.find_ids(items, param_name)
      if param_name.is_a?(Array)
        result = items.lazy.select { |x| param_name.include?(x['name']) }.map { |x| x['id'] }.to_a
        result.empty? ? nil : result
      else
        items.find { |x| x['name'] == param_name }&.dig('id')
      end
    end

    def debug_log(message)
      puts message if @debug
    end
  end
end
