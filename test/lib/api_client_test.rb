# frozen_string_literal: true

require 'test_helper'

class ApiClientTest < Minitest::Test
  def setup
    @base_url = HarvestTime::ApiClient::API_URL
    @client = HarvestTime::ApiClient.new
  end

  def test_hash_to_query_param
    assert_equal '', @client.hash_to_query_param(project_id: nil)

    assert_equal 'project_id=1', @client.hash_to_query_param(project_id: 1)

    assert_equal 'project_id=1&task_ids[]=1&task_ids[]=2',
                 @client.hash_to_query_param(project_id: 1, 'task_ids[]' => [1, 2])
  end

  def test_construct_uri
    @client.instance_variable_set(:@action, 'test_action')
    @client.instance_variable_set(:@query, {})
    assert_equal URI("#{@base_url}/test_action"), @client.construct_uri(page: nil)

    @client.instance_variable_set(:@query, {})
    assert_equal URI("#{@base_url}/test_action?page=1"), @client.construct_uri(page: 1)

    @client.instance_variable_set(:@query, { test_param: 1 })
    assert_equal URI("#{@base_url}/test_action?page=2&test_param=1"), @client.construct_uri(page: 2)
  end

  def test_construct_uri_per_page
    @client.instance_variable_set(:@action, 'test_action')
    @client.instance_variable_set(:@query, {})
    @client.per_page = 10
    assert_equal URI("#{@base_url}/test_action?page=1&per_page=10"), @client.construct_uri(page: 1)
  end

  def test_run
    assert_raises NotImplementedError do
      @client.run(action: 'test_action', query: { test_param: 1 })
    end

    @client.stub :run_get_query, 'test_result' do
      assert_equal 'test_result', @client.run(action: HarvestTime::ApiClient::TIME_ENTRIES, query: { test_param: 1 })
    end
  end

  def test_run_get_query
    @client.instance_variable_set(:@action, 'test_result')

    @client.stub :perform, mock_response(page: 1, data: nil, last_page: true) do
      assert_equal [], @client.run_get_query
    end

    @client.stub :perform, mock_response(page: 1, data: [1, 2, 3], last_page: true) do
      assert_equal [1, 2, 3], @client.run_get_query
    end
  end

  def test_run_get_query_multiple_pages
    @client.instance_variable_set(:@action, 'test_result')
    response = mock_response(page: 1, data: [1, 2, 3], last_page: false)
    mock_response(page: 2, data: [4, 5, 6], last_page: true, mocked: response)
    @client.stub :perform, response do
      assert_equal [1, 2, 3, 4, 5, 6], @client.run_get_query
    end
  end

  def test_perform
    uri = URI('https://example.com')
    Net::HTTP.stub(:start, 'response') { assert_nil @client.perform(uri) }

    response = Net::HTTPSuccess.new('1.1', '200', 'OK')
    Net::HTTP.stub(:start, response) { assert_equal response, @client.perform(uri) }

    Net::HTTP.stub :start, Net::HTTPNotFound.new('1.1', '404', 'Not Found') do
      assert_raises(StandardError) { @client.perform(uri) }
    end
  end

  def test_perform_unauthorized
    ENV['HARVEST_ACCESS_TOKEN'] = '***'
    assert_raises(HarvestTime::InvalidCredentialsError) do
      VCR.use_cassette('get_projects_unauthorized') do
        @client.perform(URI("#{@base_url}/#{HarvestTime::ApiClient::PROJECTS}"))
      end
    end
  end

  def mock_response(page:, data:, last_page:, mocked: nil)
    response = mocked || Minitest::Mock.new
    response.expect :body, mock_body(page: page, data: data, last_page: last_page)
    response.expect :nil?, data.nil?
    response
  end

  def mock_body(page:, data:, last_page: false)
    {
      'test_result' => data,
      'next_page' => last_page ? nil : page + 1
    }.to_json
  end
end
