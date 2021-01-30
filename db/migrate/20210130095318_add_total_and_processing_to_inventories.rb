class AddTotalAndProcessingToInventories < ActiveRecord::Migration[6.0]
  def change
    add_column :inventories, :procssing, :integer
    add_column :inventories, :total, :integer
  end
end
