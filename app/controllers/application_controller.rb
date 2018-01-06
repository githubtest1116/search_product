class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  include SessionsHelper
  
  private
  
  def require_user_logged_in
  	unless logged_in?
  		redirect_to login_url
  	end
  end

  def read_rakuten(result)
    code = result['itemCode']
    name = result['itemName']
    price = result['itemPrice'].to_i
    url = result['itemUrl']
    company = '楽天'
    image_url = result['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')
    
    return {
      code: code,
      name: name,
      price: price,
      url: url,
      company: company,
      image_url: image_url,
    }
  end
  
  def read_yahoo(result)
    code = result[:Code]
    name = result[:Name]
    price = result[:PriceLabel][:DefaultPrice].to_i
    url = result[:Url]
    company = 'Yahoo!'
    image_url = result[:ExImage][:Url]
    
    return {
      code: code,
      name: name,
      price: price,
      url: url,
      company: company,
      image_url: image_url,
    }
  end
  
  def read_yahoo_itemLookup(result)
    code = result[:ResultSet][:"0"][:Result][:ItemCode][:"0"][:Code]
    name = result[:ResultSet][:"0"][:Result][:"0"][:Name]

    if result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:SalePrice] != ""
      price = result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:SalePrice].to_i
    else
      price = result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:DefaultPrice].to_i
    end

    url = result[:ResultSet][:"0"][:Result][:"0"][:Url]
    company = 'Yahoo!'
    image_url = result[:ResultSet][:"0"][:Result][:"0"][:ExImage][:Url]
    
    return {
      code: code,
      name: name,
      price: price,
      url: url,
      company: company,
      image_url: image_url,
    }
  end
  
  def read_yahoo_itemLookup_update(result)
    code = result[:ResultSet][:"0"][:Result][:ItemCode][:"0"][:Code]
    name = result[:ResultSet][:"0"][:Result][:"0"][:Name]
    
    if result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:SalePrice] != ""
      price = result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:SalePrice].to_i
    else
      price = result[:ResultSet][:"0"][:Result][:"0"][:PriceLabel][:DefaultPrice].to_i
    end
    
    url = result[:ResultSet][:"0"][:Result][:"0"][:Url]
    company = 'Yahoo!'
    image_url = result[:ResultSet][:"0"][:Result][:"0"][:ExImage][:Url]
    
    return {
      code: code,
      name: name,
      price: price,
      url: url,
      company: company,
      image_url: image_url,
    }
  end

end
