# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CancelPipelineWorker, :aggregate_failures, feature_category: :continuous_integration do
  let!(:pipeline) { create(:ci_pipeline, :running) }

  describe '#perform' do
    subject(:perform) { described_class.new.perform(pipeline.id, pipeline.id) }

    let(:cancel_service) { instance_double(::Ci::CancelPipelineService) }

    it 'cancels the pipeline' do
      allow(::Ci::Pipeline).to receive(:find_by_id).and_return(pipeline)
      expect(::Ci::CancelPipelineService)
        .to receive(:new)
        .with(
          pipeline: pipeline,
          current_user: nil,
          auto_canceled_by_pipeline_id:
          pipeline.id,
          cascade_to_children: false)
        .and_return(cancel_service)

      expect(cancel_service).to receive(:force_execute)

      perform
    end

    context 'if pipeline is deleted' do
      subject(:perform) { described_class.new.perform(non_existing_record_id, non_existing_record_id) }

      it 'does not error' do
        expect(::Ci::CancelPipelineService).not_to receive(:new)

        perform
      end
    end

    describe 'with builds and state transition side effects', :sidekiq_inline do
      let!(:build) { create(:ci_build, :running, pipeline: pipeline) }

      it_behaves_like 'an idempotent worker', :sidekiq_inline do
        let(:job_args) { [pipeline.id, pipeline.id] }

        it 'cancels the pipeline' do
          perform

          pipeline.reload

          expect(pipeline).to be_canceled
          expect(pipeline.builds.first).to be_canceled
          expect(pipeline.builds.first.auto_canceled_by_id).to eq pipeline.id
          expect(pipeline.auto_canceled_by_id).to eq pipeline.id
        end
      end
    end
  end
end
