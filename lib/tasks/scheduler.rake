desc "This task is called by the Heroku scheduler add-on"
task :update_sales => :environment do
  puts "Updating feed..."
  end_date = (Time.now.utc - 32.hours)
  start_date = end_date - 1.day
  begin
    Sale.fetch_amzn_sales(start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    puts "Successfully imported sales Data!"
  rescue AmazonApiService::ProcessingError
    puts "Error occured with processing amazon api fetch request"
  rescue CsvConverter::ProcessingError
    puts "Error occured with csv processing"
  end
end

task :update_inventory => :environment do
  begin
    Inventory.fetch_amzn_inventory
    puts "Successfully imported Inventory Data!"
  rescue AmazonApiService::ProcessingError
    puts "Error occured with processing amazon api fetch request"
  rescue CsvConverter::ProcessingError
    puts "Error occured with csv processing"
  end
end
