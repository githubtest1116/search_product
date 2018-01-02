class OwnershipsController < ApplicationController
	def create
    @item = Item.find_or_initialize_by(code: params[:item_code])
    
    unless @item.persisted?

      #各社の商品検索APIを呼び出す
      #楽天
      results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)

<<-PAGE
      if results == nil
        #Amazon
        #results = 
      end

      if results == nil
        #Yahoo
        #results = 
      end
PAGE
      #ここから共通
      @item = Item.new(read_rakuten(results.first))
      @item.save
      flash[:success] = "お気に入りに登録しました"    
    ####
    #暫定で追加中
    #else
    #  flash[:danger] = "商品は既に登録されています"
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
