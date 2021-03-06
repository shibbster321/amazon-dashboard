require "csv"
require "date"

class CsvConverter
  class ProcessingError < StandardError; end
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
      puts title
      puts sku
      new_sale = Sale.new({store: store, date: date, orderid: order_id, sku: sku, qty: qty, sale_amt: sale_amt.round(2) })
      puts " "
      puts new_sale
      puts " "
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
        puts "-----------------------------------"
        puts "sale already exists or other error"
        puts "------------------------------------"
      end
    end
    return "success"
  end

  def to_inventory
      @csv.each do |row|
      location = "amazon"
      date = (Time.now.utc - 8.hours).to_date
      available = row['afn-fulfillable-quantity'].to_i
      sku = row['sku']
      inbound = row['afn-inbound-shipped-quantity'].to_i
      reserved = row['afn-reserved-quantity'].to_i
      total = row['afn-warehouse-quantity'].to_i
      title = row['product-name'].slice(0..20)

      new_inventory = Inventory.new({location: location, date: date, available: available, sku: sku, reserved: reserved, total: total })
      if product = Product.find_by(sku: new_inventory.sku)
          new_inventory.product_id = product.id
          if Sale.weekly_sale_of(product.id)
            puts Sale.weekly_sale_of(product.id)
            new_inventory.supply_days = available / Sale.weekly_sale_of(product.id) * 7
          else
            new_inventory.supply_days = available / 1 * 7
          end
      else #if the product does not exist
        if ProductType.find_by(title: title) then ptype = ProductType.find_by(title: title) else ptype = ProductType.create({title: title}) end
        product = Product.create({product_type_id: ptype.id, title: title, sku: new_inventory.sku, color_size: "unkown"})
        new_inventory.product_id = product.id
          if Sale.weekly_sale_of(product.id)
            new_inventory.supply_days = available / Sale.weekly_sale_of(product.id) * 7
          else
            new_inventory.supply_days = available / 1 * 7
          end
      end
      if new_inventory.save
        puts new_inventory.sku + " inventory saved"
      else
        puts "inventory already exists or other error"
      end
    end
    return "success"
  end
end
