# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::TimelineEventTag::Create do
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_reload(:project) { create(:project) }

  let(:args) { { name: 'Test tag 1' } }

  before do
    project.add_maintainer(current_user)
  end

  specify { expect(described_class).to require_graphql_authorizations(:admin_incident_management_timeline_event_tag) }

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(project_path: project.full_path, **args) }

    context 'when user has permission to create timeline event tag' do
      it 'adds the tag to the project' do
        expect { resolve }.to change(IncidentManagement::TimelineEventTag, :count).by(1)
        expect(project.incident_management_timeline_event_tags.by_names(['Test tag 1']).pluck_names)
          .to match_array(['Test tag 1'])
      end
    end

    context 'when TimelineEventTags::CreateService responds with an error' do
      let(:args) { {} }

      it 'returns errors' do
        expect(resolve).to eq(timeline_event_tag: nil, errors: ["Name can't be blank and Name is invalid"])
      end
    end

    context 'when user has no permissions to create tags on a project' do
      before do
        project.add_developer(current_user)
      end

      it 'raises an error' do
        expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end

  private

  def mutation_for(project, user)
    described_class.new(object: project, context: { current_user: user }, field: nil)
  end
end
