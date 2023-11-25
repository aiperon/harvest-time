# frozen_string_literal: true

require 'net/http'
require 'dotenv'
require 'json'

module HarvestTime
  # This class is responsible for making the request to the Harvest API
  class ApiClient
    API_URL = 'https://api.harvestapp.com/v2'

    PROJECTS = 'projects'
    TASKS = 'tasks'
    CLIENTS = 'clients'
    TIME_ENTRIES = 'time_entries'

    ACTIONS = [PROJECTS, TASKS, CLIENTS, TIME_ENTRIES].freeze

    attr_accessor :per_page

    def initialize(debug: false)
      Dotenv.load

      raise ArgumentError, 'HARVEST_ACCESS_TOKEN is missing as env param' if ENV['HARVEST_ACCESS_TOKEN'].nil?

      raise ArgumentError, 'HARVEST_ACCOUNT_ID is missing as env param' if ENV['HARVEST_ACCOUNT_ID'].nil?

      @debug = debug
    end

    def run(action: TIME_ENTRIES, query: {})
      raise NotImplementedError, "Harvest: unknown action #{action}" unless ACTIONS.include?(action)

      @query = query
      @action = action

      run_get_query
      # TODO: implement POST queries
    end

    def run_get_query
      page = 1
      data = []
      until page.nil?
        response = perform(construct_uri(page: page))
        break if response.nil?

        json = JSON.parse(response.body)

        # We could rely on Harvest API convention:
        # It returns result in endpoint name (ex. /time_entries returns { time_entries: [], ...})
        data += json[@action] if json.key?(@action)
        page = json['next_page']
      end
      data
    end

    def perform(uri)
      debug_log "Harvest: request #{uri}"
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http&.request_get(uri, auth_headers)
      end

      return response if response.is_a?(Net::HTTPSuccess)
      return nil unless response.is_a?(Net::HTTPResponse)

      raise InvalidCredentialsError, "Invalid credentials for #{uri}" if response.code == '401'

      raise StandardError, "No response for #{uri}\nResponse: #{response.code} #{response.message}"
    end

    def construct_uri(page:)
      path = @action
      params = page ? "page=#{page}" : ''
      params += "&per_page=#{@per_page}" if @per_page
      unless @query.nil?
        query = hash_to_query_param(@query)
        params += "&#{query}" unless query.empty?
      end
      path += "?#{params}" unless params.empty?
      URI("#{API_URL}/#{path}")
    end

    def hash_to_query_param(query)
      query.map do |key, value|
        next if value.nil?

        value.is_a?(Array) ? value.map { |v| "#{key}=#{v}" }.join('&') : "#{key}=#{value}"
      end.compact.join('&')
    end

    private

    def auth_headers
      {
        'Authorization' => "Bearer #{ENV['HARVEST_ACCESS_TOKEN']}",
        'Harvest-Account-Id' => ENV['HARVEST_ACCOUNT_ID'],
        'Accept' => 'application/json'
      }
    end

    def debug_log(message)
      puts message if @debug
    end
  end
end
