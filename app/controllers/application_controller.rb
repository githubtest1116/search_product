class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  include SessionsHelper
  
  private
  
  def require_user_logged_in
  	unless logged_in?
  		redirect_to login_url
  	end
  end

  def read(result)
    code = result['itemCode']
    name = result['itemName']
    price = result['itemPrice']
    url = result['itemUrl']
    image_url = result['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')
    
    return {
      code: code,
      name: name,
      price: price,
      url: url,
      image_url: image_url,
    }
  end

end
