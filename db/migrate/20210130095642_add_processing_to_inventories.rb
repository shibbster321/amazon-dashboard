class AddProcessingToInventories < ActiveRecord::Migration[6.0]
  def change
    add_column :inventories, :processing, :integer
  end
end
