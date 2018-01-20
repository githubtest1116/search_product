class OwnershipsController < ApplicationController
  require 'uri'
  require 'open-uri'
  require 'json'

	def create
    @item = Item.find_or_initialize_by(code: params[:item_code])
    
    unless @item.persisted?
      ##各社の商品検索APIを呼び出す
      #Yahoo!
      yahoo_application_id = ENV['YAHOO_APPID']
      yahoo_url = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemLookup"
      url = yahoo_url + "?appid=" + yahoo_application_id + "&itemcode=" + @item.code + "&image_size=132"
      result = JSON.parse(open(url).read, symbolize_names: true)
      
      if result[:ResultSet][:totalResultsReturned] != "0"
        @item = Item.new(read_yahoo_itemLookup(result))
      else
      #楽天
        results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
        @item = Item.new(read_rakuten(results.first))
      end

      @item.save
    end
    flash[:success] = "お気に入りに登録しました"
    current_user.want(@item)

    redirect_back(fallback_location: root_url)
	end

	def destroy
		@item = Item.find(params[:item_id])

		current_user.unwant(@item)
		flash[:success] = "お気に入りを解除しました"
		redirect_back(fallback_location: root_url)
		
	end
	
	private

end
