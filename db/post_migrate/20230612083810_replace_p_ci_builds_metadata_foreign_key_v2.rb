# frozen_string_literal: true

class ReplacePCiBuildsMetadataForeignKeyV2 < Gitlab::Database::Migration[2.1]
  include Gitlab::Database::PartitioningMigrationHelpers
  include Gitlab::Database::MigrationHelpers::WraparoundAutovacuum

  disable_ddl_transaction!

  def up
    return unless should_run?

    add_concurrent_partitioned_foreign_key :p_ci_builds_metadata, :p_ci_builds,
      name: 'temp_fk_e20479742e_p',
      column: [:partition_id, :build_id],
      target_column: [:partition_id, :id],
      on_update: :cascade,
      on_delete: :cascade,
      validate: false,
      reverse_lock_order: true

    prepare_partitioned_async_foreign_key_validation :p_ci_builds_metadata,
      name: 'temp_fk_e20479742e_p'
  end

  def down
    return unless should_run?

    unprepare_partitioned_async_foreign_key_validation :p_ci_builds_metadata, name: 'temp_fk_e20479742e_p'

    Gitlab::Database::PostgresPartitionedTable.each_partition(:p_ci_builds_metadata) do |partition|
      execute "ALTER TABLE #{partition.identifier} DROP CONSTRAINT IF EXISTS temp_fk_e20479742e_p"
    end
  end

  private

  def should_run?
    can_execute_on?(:ci_builds_metadata, :ci_builds)
  end
end
