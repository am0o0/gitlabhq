# frozen_string_literal: true

require 'rake_helper'

RSpec.describe 'gitlab:feature_categories:index', :silence_stdout, feature_category: :scalability do
  before do
    Rake.application.rake_require 'tasks/gitlab/feature_categories'
  end

  it 'outputs objects by stage group' do
    # Sample items that _hopefully_ won't change very often.
    expected = {
      'controller_actions' => a_hash_including(
        'integrations' => a_collection_including(
          klass: 'Oauth::JiraDvcs::AuthorizationsController',
          action: 'new',
          source_location: [
            'app/controllers/oauth/jira_dvcs/authorizations_controller.rb',
            an_instance_of(Integer)
          ]
        )
      ),
      'api_endpoints' => a_hash_including(
        'system_access' => a_collection_including(
          klass: 'API::AccessRequests',
          action: '/groups/:id/access_requests',
          source_location: [
            'lib/api/access_requests.rb',
            an_instance_of(Integer)
          ]
        )
      ),
      'sidekiq_workers' => a_hash_including(
        'source_code_management' => a_collection_including(
          klass: 'MergeWorker',
          source_location: [
            'app/workers/merge_worker.rb',
            an_instance_of(Integer)
          ]
        )
      ),
      'database_tables' => a_hash_including(
        'continuous_integration' => a_collection_including('ci_pipelines'),
        'user_profile' => a_collection_including('users')
      )
    }

    expect(YAML).to receive(:dump).with(a_hash_including(expected))

    run_rake_task('gitlab:feature_categories:index')
  end
end
