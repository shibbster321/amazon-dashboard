class RemoveTotalFromSales < ActiveRecord::Migration[6.0]
  def change
    remove_column :sales, :total, :float
  end
end
