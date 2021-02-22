Etsy.api_key = ENV["ETSY_KEY"]
Etsy.api_secret = ENV["ETSY_SECRET"]
Etsy.callback_url = if ENV['APPLICATION_URL'] then "#{ENV['APPLICATION_URL']}etsyauthorize" else "http://localhost:3000/etsyauthorize" end
Etsy.environment = :production
