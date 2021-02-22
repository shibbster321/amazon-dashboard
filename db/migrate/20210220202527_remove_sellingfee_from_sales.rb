class RemoveSellingfeeFromSales < ActiveRecord::Migration[6.0]
  def change
    remove_column :sales, :selling_fee, :float
  end
end
