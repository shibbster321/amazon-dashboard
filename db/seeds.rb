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
# puts "destryed Inventory seeds"
# table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', 'inventory_data.csv')), headers: true)
# # Create Inventory events
# table.each do |row|
#   if row[0].to_date then "" else puts "date format must be year-month-day" end
#   new = Inventory.new({date: row[0].to_date, sku: row[4], asin: row[5], inbound: row[14].to_i, available: row[15].to_i, supply_days: row[21].to_i, total: row[13].to_i})
#   puts "new inventory made"
#   product = Product.find_by(asin: new.asin)
#   puts "product_id identified"
#   new.product_id = product.id
#   if new.save
#     puts new.asin + " saved"
#     new.processing = new.total - new.inbound - new.available
#     new.save
#     puts "processing added"
#   else
#     puts "product already exists or error"
#   end

# end


# Sale.destroy_all
# puts "destryed sale seeds"
# table = CSV.parse(File.read(File.join(Rails.root, 'app', 'assets', 'data', 'sales_data.csv')), headers: true)
# # Create sale events
# table.each do |row|
#   if row['type'] == "Order"
#     new = Sale.new({date: row[0].to_time, orderid: row['order id'], sku: row['sku'].to_s, qty: row['quantity'].to_i, sale_amt: row['product sales'].to_i, selling_fee: row['selling fees'].to_f, fba_fee: row['fba fees'].to_f, total: row['total'].to_f})
#     if Product.find_by(sku: new.sku)
#       product = Product.find_by(sku: new.sku)
#       new.product_id = product.id
#       new.product_type_id = product.product_type_id
#     else
#       pt = ProductType.create({title: row[5]})
#       new.product_type_id = pt.id
#       product = Product.create({product_type_id: pt.id, sku: new.sku, asin: "unkown", color_size: "unkown"})
#       new.product_id = product.id
#     end
#     if new.save
#       puts new.sku + " sale saved"

#     else
#       puts "sale already exists or error"
#     end
#   else
#     puts "not an order"
#   end
# end


#Fetching API
response = AmazonApiService.new("/orders/v0/orders?MarketplaceIds=ATVPDKIKX0DER&CreatedAfter=2021-01-01").call
response['payload']['Orders'].map do |row|
  order_id = row["AmazonOrderId"]
  order = AmazonApiService.new("/orders/v0/orders/#{order_id}/orderItems").call;
  sku = order['payload']['OrderItems'][0]['SellerSKU']

  new = Sale.new( {date: row['PurchaseDate'].to_time, orderid: order_id, sku: sku, qty: order['payload']['OrderItems'][0]['ProductInfo']['NumberOfItems'].to_i, sale_amt: order['payload']['OrderItems'][0]['ItemPrice']['Amount'].to_f, selling_fee: row['selling fees'].to_f, fba_fee: row['fba fees'].to_f, total: row['total'].to_f})})
# end


