# frozen_string_literal: true

class AddProjectFkToCatalogResourceComponents < Gitlab::Database::Migration[2.1]
  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :catalog_resource_components, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key :catalog_resource_components, column: :project_id
    end
  end
end
