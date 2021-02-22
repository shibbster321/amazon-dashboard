class AddFbafeeToSales < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :fba_fee, :float
  end
end
