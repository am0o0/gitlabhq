# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TreeEntryPresenter do
  include Gitlab::Routing.url_helpers

  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:tree) { Gitlab::Graphql::Representation::TreeEntry.new(repository.tree.trees.first, repository) }
  let(:presenter) { described_class.new(tree) }

  describe '.web_url' do
    it { expect(presenter.web_url).to eq("http://localhost/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}") }
  end

  describe '#web_path' do
    it { expect(presenter.web_path).to eq("/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}") }
  end

  context 'when blob has ref_type' do
    before do
      tree.ref_type = 'heads'
    end

    describe '.web_url' do
      it { expect(presenter.web_url).to eq("http://localhost/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}?ref_type=heads") }
    end

    describe '#web_path' do
      it {
        expect(presenter.web_path).to eq("/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}?ref_type=heads")
      }
    end
  end
end
