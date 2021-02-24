class RenameProcessingToReservedInInventory < ActiveRecord::Migration[6.0]
  def change
    rename_column :inventories, :processing, :reserved
  end
end
