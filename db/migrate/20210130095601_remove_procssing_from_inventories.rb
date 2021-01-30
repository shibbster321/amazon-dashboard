class RemoveProcssingFromInventories < ActiveRecord::Migration[6.0]
  def change
    remove_column :inventories, :procssing, :integer
  end
end
