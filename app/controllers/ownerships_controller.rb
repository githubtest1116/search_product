class OwnershipsController < ApplicationController
	def create
    @item = Item.find_or_initialize_by(code: params[:item_code])
    @item = Item.find_or_initialize_by(code: params[:item_code])
    
    unless @item.persisted?
      flash[:success] = "お気に入りに登録しました"
      results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
      
      #うーん、なぜかreadメソッドが動かない・・・
      #とりあえず直打ちに設定しておく
      #@item = Item.new(read(results.first))
      
        @item.code = results.first['itemCode']
        @item.name = results.first['itemName']
        @item.price = results.first['itemPrice']
        @item.url = results.first['itemUrl']
        @item.image_url = results.first['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')

      @item.save
    
    ####
    #暫定で追加中
    else
      flash[:danger] = "商品は既に登録されています"
    #####
    end
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
