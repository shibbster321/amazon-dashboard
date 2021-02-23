class AddLocationToInventories < ActiveRecord::Migration[6.0]
  def change
    add_column :inventories, :location, :string
  end
end
