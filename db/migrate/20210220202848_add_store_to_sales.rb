class AddStoreToSales < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :store, :string
  end
end
