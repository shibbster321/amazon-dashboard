class AddFbafeeToProductType < ActiveRecord::Migration[6.0]
  def change
    add_column :product_types, :fba_fee, :float
  end
end
