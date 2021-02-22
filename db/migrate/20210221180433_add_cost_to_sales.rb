class AddCostToSales < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :cost, :float
  end
end
