class EtsyApiService

  def initialize(url)
    @url = url
  end
  def call
    Etsy.api_key = ENV["ETSY_KEY"]
    Etsy.api_secret = ENV["ETSY_SECRET"]
    Etsy.callback_url = 'http://localhost:3000/authorize'

    request_token = Etsy.request_token
    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret
    redirect Etsy.verification_url
    puts "first done"
  end

    def etsyauthorize
      access_token = Etsy.access_token(
        session[:request_token],
        session[:request_secret],
        params[:oauth_verifier]
  )
  # access_token.token and access_token.secret can now be saved for future API calls
    end

  end
  private

end
