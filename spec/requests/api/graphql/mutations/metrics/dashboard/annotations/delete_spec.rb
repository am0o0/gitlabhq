# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Metrics::Dashboard::Annotations::Delete, feature_category: :metrics do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project, :private, :repository) }
  let_it_be(:annotation) { create(:metrics_dashboard_annotation) }

  let(:variables) { { id: GitlabSchema.id_from_object(annotation).to_s } }
  let(:mutation)  { graphql_mutation(:delete_annotation, variables) }

  def mutation_response
    graphql_mutation_response(:delete_annotation)
  end

  before do
    stub_feature_flags(remove_monitor_metrics: false)
  end

  specify { expect(described_class).to require_graphql_authorizations(:admin_metrics_dashboard_annotation) }

  context 'when the user has permission to delete the annotation' do
    before do
      project.add_developer(current_user)
    end

    context 'with invalid params' do
      let(:variables) { { id: GitlabSchema.id_from_object(project).to_s } }

      it_behaves_like 'a mutation that returns top-level errors' do
        let(:match_errors) { contain_exactly(include('invalid value for id')) }
      end
    end

    context 'when metrics dashboard feature is unavailable' do
      before do
        stub_feature_flags(remove_monitor_metrics: true)
      end

      it_behaves_like 'a mutation that returns top-level errors',
        errors: [Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR]
    end
  end

  context 'when the user does not have permission to delete the annotation' do
    before do
      project.add_reporter(current_user)
    end

    it_behaves_like 'a mutation that returns top-level errors', errors: [Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR]

    it 'does not delete the annotation' do
      expect do
        post_graphql_mutation(mutation, current_user: current_user)
      end.not_to change { Metrics::Dashboard::Annotation.count }
    end
  end
end
