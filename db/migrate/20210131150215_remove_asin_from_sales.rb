class RemoveAsinFromSales < ActiveRecord::Migration[6.0]
  def change
    remove_column :sales, :asin, :string
  end
end
