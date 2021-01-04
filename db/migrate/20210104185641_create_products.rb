class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :title
      t.string :asin
      t.string :color_size
      t.text :description
      t.integer :inventory_amount
      t.string :sku
      t.references :product_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
