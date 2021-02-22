class AddProfitToSale < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :profit, :float
  end
end
