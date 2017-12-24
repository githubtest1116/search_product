class ItemsController < ApplicationController
  def new
    @items = []
    
    @keyword = params[:keyword]
    
    if @keyword
      results = RakutenWebService::Ichiba::Item.search({
        keyword: @keyword,
        imageFlag: 1,
        hits: 20,
      })
      
      results.each do |result|
        item = Item.new(read(result))
        @items << item
      end
    end
  end
  
  def show
    @item = Item.find(params[:id])
  end
  
  def create
    @item = Item.find_or_initialize_by(code: params[:item_code])
    
    unless @item.persisted?
      flash[:success] = "商品を登録しました"
      results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
      
      @item = Item.new(read(results.first))
      @item.save
    else
      flash[:danger] = "商品は既に登録されています"
    end
    
    
    redirect_back(fallback_location: root_url)
  end

  private
  
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
