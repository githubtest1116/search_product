class ItemsController < ApplicationController
  require 'uri'
  require 'open-uri'
  require 'json'

  def new
    @items = []
    
    @keyword = params[:keyword]
    
    if @keyword.present?
      #楽天API呼び出し
      rakuten
      #Yahoo! API呼び出し
      yahoo
    end
    
    #binding.pry
    @items = @items.sort{|a,b| a.price.to_i <=> b.price.to_i}
  end
  
  def create
    @item = Item.find_by(code: params[:item_code])
    
    ##各社の商品検索APIを呼び出す
    #Yahoo!
    yahoo_application_id = ENV['YAHOO_APPID']
    yahoo_url = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemLookup"
    url = yahoo_url + "?appid=" + yahoo_application_id + "&itemcode=" + @item.code + "&image_size=132"
    result = JSON.parse(open(url).read, symbolize_names: true)
    
    if result[:ResultSet][:totalResultsReturned] != "0"
      @item = Item.new(read_yahoo_itemLookup_update(result))
    else
      #楽天
      results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
      @item = Item.new(read_rakuten(results.first))
    end

    @item.save
    flash[:success] = "価格情報を更新しました" 
    redirect_back(fallback_location: root_url)
  end
  
  def show
    @item = Item.find(params[:id])

    #横軸
    #xAxis_categories = ['2013-11-09', '2013-11-10', '2013-11-11', '2013-11-12']
    xAxis_categories = []
    
    #横軸の間隔
    tickInterval = 1
    
    #縦軸
    #data = [120, 80, 90, 150]
    yAxis_data = []
    
    results = Item.where(code: @item.code)
    
    results.each do |result|
      xAxis_categories << result.created_at.strftime('%Y年%m月%d日')
      yAxis_data << result.price.to_i
    end
    
    #最新の7日間のみに整形
    xAxis_categories = xAxis_categories.last(7)
    yAxis_data = yAxis_data.last(7)

    @graph_data = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '価格推移')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)
      f.series(name: '価格推移', data: yAxis_data, type: 'spline')
      
      f.yAxis(title: {text: '円'})
    end
  end
  
  private
  
  def rakuten
    results = RakutenWebService::Ichiba::Item.search({
      keyword: @keyword,
      imageFlag: 1,
      hits: 20,
    })
    results.each do |result|
      item = Item.find_or_initialize_by(read_rakuten(result))
      @items << item
    end
  end
  
  def yahoo
    #APPIDをセット
    yahoo_application_id = ENV['YAHOO_APPID']
    
    #URL組み立て
    yahoo_url = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    yahoo_url = yahoo_url + "?appid=" + yahoo_application_id
    url = yahoo_url + "&query=" + @keyword + "&image_size=132" + "&hits=20"
    url = URI.encode(url)

    #HTTPS通信
    results_yahoo = JSON.parse(open(url).read, symbolize_names: true)
    
    #ハッシュから配列へ変換
    results_yahoo = results_yahoo[:ResultSet][:"0"][:Result].values
    
    #不要なキーを削除
    results_yahoo.shift
    results_yahoo.shift
    results_yahoo.pop 

    results_yahoo.each do |result|
      item = Item.find_or_initialize_by(read_yahoo(result))
      @items << item
    end
  end
end
