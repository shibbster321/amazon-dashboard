class AddBlurbToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :blurb, :string
  end
end
