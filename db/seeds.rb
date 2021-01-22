# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

User.create([{ name: 'Sample User', email: 'scX92m22c@yopmail.com', password: "tester12", remember_created_at: nil }])

table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', 'inventory data.csv')), headers: true)

# Create Product Types
table.each do |row|
 new = ProductType.new({title: row[0]})
  if new.save
  puts new.title + " saved"
 else
  puts "product already exists"
 end
end

# Create Children Products
table.each do |row|
 new = Product.new({title: row[0], description: row[1], sku: row[2], asin: row[3], price: row[4], color_size: row[5]})
  ProductType.all.each do |product_type|
    if product_type.title == new.title then new.product_type_id = product_type.id end
  end
  if new.save
    puts new.title + " saved"
 else
  puts "product already exists"
 end
end

