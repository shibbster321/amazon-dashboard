class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.datetime :date
      t.references :product, null: false, foreign_key: true
      t.references :product_type, null: false, foreign_key: true
      t.string :asin
      t.string :sku
      t.string :orderid
      t.integer :qty
      t.float :sale_amt
      t.float :selling_fee
      t.float :fba_fee
      t.float :total

      t.timestamps
    end
  end
end
