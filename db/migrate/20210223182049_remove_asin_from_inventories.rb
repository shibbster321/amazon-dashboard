class RemoveAsinFromInventories < ActiveRecord::Migration[6.0]
  def change
    remove_column :inventories, :asin, :string
  end
end
