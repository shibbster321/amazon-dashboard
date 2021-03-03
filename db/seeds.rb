# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

require 'csv'
require 'time'
require 'date'
# User.destroy_all
# User.create([{ name: 'cameron', email: 'cameron@gmail.com', password: "password", status: "admin", remember_created_at: nil }])

# table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', 'product_data.csv')), headers: true)

# # Create Product Types
# ProductType.destroy_all
# table.each do |row|
#  new = ProductType.new({title: row[0]})
#   if new.save
#   puts new.title + " saved"
#  else
#   puts "product already exists"
#  end
# end

# # Create Children Products
# Product.destroy_all
# table.each do |row|
#  new = Product.new({title: row[0], description: row[1], sku: row[2], asin: row[3], price: row[4], color_size: row[5]})
#   ProductType.all.each do |product_type|
#     if product_type.title == new.title then new.product_type_id = product_type.id end
#   end
#   if new.save
#     puts new.title + " saved"
#  else
#   puts "product already exists"
#  end
# end

# Inventory.destroy_all
# puts "all inventory destroyed"
# puts "creating inventory event"
new = Inventory.new({date: "2021-01-01".to_date, location: "amazon", sku: Product.first.sku, inbound: 5, available: 5, supply_days: 5, total: 5, reserved: 5})
new.product_id = Product.first.id
if new.save
  "seed inventory saved"
else
  puts "error or alredy exists"
end


# table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', 'inventory_data.csv')), headers: true)
# # Create Inventory events
# table.each do |row|
#   if row[0].to_date then "" else puts "date format must be year-month-day" end
#   new = Inventory.new({date: row[0].to_date, location: "avids", sku: row[4], inbound: row[14].to_i, available: row[15].to_i, supply_days: row[21].to_i, total: row[13].to_i})
#   puts "new inventory made"
#   product = Product.find_by(sku: new.sku)
#   puts "product_id identified"
#   new.product_id = product.id
#   if new.save
#     puts new.sku + " saved"
#     new.reserved = new.total - new.inbound - new.available
#     new.save
#     puts "processing added"
#   else
#     puts "product already exists or error"
#   end

# end


# Sale.destroy_all
puts "Importing Data"
table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', '2_years_of_sales.csv')), headers: true)
# Create sale events
table.each do |row|
  if row['type'] == "Order"
    title = row['description'].slice(0..20)
    new_sale = Sale.new({store: "amazon", date: row[0].to_time, orderid: row['order id'], sku: row['sku'].to_s, qty: row['quantity'].to_i, sale_amt: row['product sales'].to_f})
    if Product.find_by(sku: new_sale.sku)
        product = Product.find_by(sku: new_sale.sku)
        new_sale.product_id = product.id
        new_sale.product_type_id = product.product_type_id
    else #if the product does not exist
      if ProductType.find_by(title: title) then ptype = ProductType.find_by(title: title) else ptype = ProductType.create({title: title}) end
      new_sale.product_type_id = ptype.id
      product = Product.create({product_type_id: ptype.id, title: title, sku: new_sale.sku, asin: "unkown", color_size: "unkown"})
      new_sale.product_id = product.id
    end
    if new_sale.save
      puts new_sale.sku + " sale saved"
    else
      puts "sale already exists or other error"
    end
  else
    ""
  end
end




