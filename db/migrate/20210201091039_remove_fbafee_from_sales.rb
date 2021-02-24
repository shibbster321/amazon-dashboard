class RemoveFbafeeFromSales < ActiveRecord::Migration[6.0]
  def change
    remove_column :sales, :fba_fee, :float
  end
end
