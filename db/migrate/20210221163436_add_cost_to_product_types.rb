class AddCostToProductTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :product_types, :cost, :float
  end
end
