# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleToRemoveInvalidDeployAccessLevelGroups, feature_category: :continuous_delivery do
  let!(:batched_migration) { described_class::MIGRATION }

  it 'schedules a new batched migration' do
    reversible_migration do |migration|
      migration.before -> {
        expect(batched_migration).not_to have_scheduled_batched_migration
      }

      migration.after -> {
        expect(batched_migration).to have_scheduled_batched_migration(
          table_name: :protected_environment_deploy_access_levels,
          column_name: :id,
          interval: described_class::DELAY_INTERVAL
        )
      }
    end
  end
end
