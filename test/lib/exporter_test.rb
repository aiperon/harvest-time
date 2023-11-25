# frozen_string_literal: true

require 'test_helper'

class ExporterTest < Minitest::Test
  def setup
    @klass = HarvestTime::Exporter
  end

  def test_filter_ids
    items = [{ 'name' => 'Task 1', 'id' => 1 }, { 'name' => 'Task 2', 'id' => 2 }, { 'name' => 'Task 3', 'id' => 3 }]
    assert_equal [1], @klass.find_ids(items, ['Task 1'])
    assert_equal [1, 3], @klass.find_ids(items, ['Task 1', 'Task 3'])

    assert_equal 1, @klass.find_ids(items, 'Task 1')
    assert_equal 2, @klass.find_ids(items, 'Task 2')
  end

  def test_export_item_ids
    exporter = init(params: { project: 'Project 1' })
    assert_equal 1, get_project_id(exporter)
    assert_nil get_task_ids(exporter)

    exporter = init(params: { tasks: 'Task 1' })
    assert_nil get_project_id(exporter)
    assert_equal [2], get_task_ids(exporter)

    exporter = init(params: { project: 'Project 1', tasks: 'Task 1,Task 2' })
    assert_equal 1, get_project_id(exporter)
    assert_equal [2, 3], get_task_ids(exporter)
  end

  def test_export_filter
    assert_equal [1, [2, 3]], export_filter_ids(init(params: { project: 'Project 1', tasks: 'Task 1,Task 2' }))
    assert_nil export_filter_ids(init(params: nil))
    assert_equal [1, nil], export_filter_ids(init(params: { project: 'Project 1' }))
    assert_equal [nil, [2]], export_filter_ids(init(params: { tasks: 'Task 1' }))
  end

  def test_export_time_entries
    exporter = init(from: '2023-10-01', to: '2023-10-31')
    time_entries = VCR.use_cassette('get_time_entries') do
      exporter.export_time_entries
    end
    assert_equal 47, time_entries.count
  end

  def test_export_time_entries_multipage
    exporter = init(from: '2023-10-01', to: '2023-10-31')
    exporter.client.per_page = 20
    time_entries = VCR.use_cassette('get_time_entries_multipage') do
      exporter.export_time_entries
    end
    assert_equal 47, time_entries.count
  end

  def test_export_time_entries_by_project
    exporter = init(from: '2023-10-01', to: '2023-10-31')
    time_entries = VCR.use_cassette('get_time_entries_by_project') do
      exporter.export_time_entries(project_id: 1)
    end
    assert_equal 13, time_entries.count
  end

  def test_export_time_entries_by_tasks
    exporter = init(from: '2023-10-01', to: '2023-10-31')
    task_ids = [3, 8]
    time_entries = VCR.use_cassette('get_time_entries_by_tasks') do
      exporter.export_time_entries(task_ids: task_ids)
    end
    assert_equal task_ids, time_entries.map { |x| x['task']['id'] }.uniq.sort
    assert_equal 27, time_entries.count
  end

  def init(from: nil, to: nil, output: nil, params: { tasks: nil, project: nil })
    @klass.new(from: from, to: to, output: output, verbose: false, params: params)
  end

  def export_filter_ids(exporter)
    VCR.use_cassette('get_projects_and_tasks') do
      exporter.export_filter_ids
    end
  end

  def get_project_id(exporter)
    VCR.use_cassette('get_projects') do
      exporter.export_item_ids(HarvestTime::ApiClient::PROJECTS, :project)
    end
  end

  def get_task_ids(exporter)
    VCR.use_cassette('get_tasks') do
      exporter.export_item_ids(HarvestTime::ApiClient::TASKS, :tasks)
    end
  end
end
