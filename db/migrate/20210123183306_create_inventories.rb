class CreateInventories < ActiveRecord::Migration[6.0]
  def change
    create_table :inventories do |t|
      t.datetime :date
      t.references :product, null: false, foreign_key: true
      t.string :asin
      t.string :sku
      t.integer :available
      t.integer :inbound
      t.integer :supply_days

      t.timestamps
    end
  end
end
