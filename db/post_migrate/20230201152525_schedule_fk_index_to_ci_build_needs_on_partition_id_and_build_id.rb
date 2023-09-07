# frozen_string_literal: true

class ScheduleFkIndexToCiBuildNeedsOnPartitionIdAndBuildId < Gitlab::Database::Migration[2.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_ci_build_needs_on_partition_id_build_id
  TABLE_NAME = :ci_build_needs
  COLUMNS = [:partition_id, :build_id]

  def up
    prepare_async_index(TABLE_NAME, COLUMNS, name: INDEX_NAME)
  end

  def down
    unprepare_async_index_by_name(TABLE_NAME, INDEX_NAME)
  end
end
