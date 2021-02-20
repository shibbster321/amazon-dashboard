Etsy.api_key = ENV["ETSY_KEY"]
Etsy.api_secret = ENV["ETSY_SECRET"]
Etsy.callback_url = "#{ENV['APPLICATION_URL'] || 'http://localhost:3000/'}authorize"
