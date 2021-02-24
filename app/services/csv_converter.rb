require "csv"
require "date"

class CsvConverter
  def initialize(csv)
    @csv = csv
  end

  def to_sales
    @csv.each do |row|
      store = "amazon"
      sale_amt = row['item-price'].to_f
      date = row['purchase-date'].to_time
      qty = row ['quantity-shipped'].to_i
      sku = row['sku']
      order_id = row ['amazon-order-id']
      title = row['product-name'].slice(0..20)
      new_sale = Sale.new({store: store, date: date, orderid: order_id, sku: sku, qty: qty, sale_amt: sale_amt.round(2) })
      if Product.find_by(sku: new_sale.sku)
          product = Product.find_by(sku: new_sale.sku)
          new_sale.product_id = product.id
          new_sale.product_type_id = product.product_type_id
      else #if the product does not exist
        if ProductType.find_by(title: "MISC") then ptype = ProductType.find_by(title: "MISC") else ptype = ProductType.create({title: "MISC"}) end
        new_sale.product_type_id = ptype.id
        product = Product.create({product_type_id: ptype.id, title: title, sku: new_sale.sku, asin: "unkown", color_size: "unkown"})
        new_sale.product_id = product.id
      end
      if new_sale.save
        puts new_sale.sku + " sale saved"
      else
        puts "sale already exists or other error"
      end
    end
  end

  def to_inventory
      @csv.each do |row|
      location = "amazon"
      date = (Time.now.utc - 8.hours).to_date
      available = row['item-price'].to_i
      sku = row['sku']
      inbound = row['afn-inbound-shipped-quantity'].to_i
      reserved = row['afn-reserved-quantity'].to_i
      total = row['afn-warehouse-quantity'].to_i

#     t.integer "supply_days"

      new_inventory = Inventory.new({location: location, date: date, available: available, sku: sku, reserved: reserved, total: total })
      if Product.find_by(sku: new_inventory.sku)
          product = Product.find_by(sku: new_inventory.sku)
          new_inventory.product_id = product.id
          new_inventory.product_type_id = product.product_type_id
      else #if the product does not exist
        if ProductType.find_by(title: "MISC") then ptype = ProductType.find_by(title: "MISC") else ptype = ProductType.create({title: "MISC"}) end
        new_inventory.product_type_id = ptype.id
        product = Product.create({product_type_id: ptype.id, title: row['product-name'], sku: new_inventory.sku, color_size: "unkown"})
        new_inventory.product_id = product.id
      end
      if new_inventory.save
        puts new_inventory.sku + " inventory saved"
      else
        puts "inventory already exists or other error"
      end
    end
  end
end
