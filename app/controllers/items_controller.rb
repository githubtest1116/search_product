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

    @items = @items.sort{|a,b| a.price.to_i <=> b.price.to_i}
  end
  
  def create
    @item = Item.find_by(code: params[:item_code])
    
    @i = 0
    #更新用API呼び出し
    update_price
    
    if @i == 0
      @item.save
      #current_user.want(@item)
      flash[:success] = "価格情報を更新しました" 
    else
      flash[:warning] = "価格情報が更新できませんでした。商品が存在するか確認してください。"
    end
    redirect_back(fallback_location: root_url) 
  end
  
  def bulk_create
    @items = current_user.ownership_items
    @count = 0

    @items.each do |item|
      @item = Item.find_by(code: item.code)
      @i = 0

      #更新用API呼び出し
      update_price
      @count = @count + @i
      
      @item.save
      #current_user.want(@item)
    end

    if @count == 0
      flash[:success] = "価格情報を一括更新しました" 
    else
      flash[:warning] = "#{@i}件の更新ができませんでした"
    end
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
    
    #results = current_user.ownership_items.where(code: @item.code)
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
  
  def item_register_url
    #render :layout => 'help_layout'
  end
  
  def item_register_info
    item_url = params[:"/items/register"][:item_url]
    @i = 0
    
    if item_url != "" && item_url.include?("farfetch.com")
      #@item = item_scraping(item_url)
      item_scraping(item_url)
      if @i == 0
        @item.save
        current_user.want(@item)
        flash[:success] = "商品を追加しました" 
      else
        flash[:warning] = "商品を追加できませんでした"
      end
      redirect_to user_path(current_user)
    elsif item_url.include?("https://quiet-meadow-28545.herokuapp.com/")
      #テスト用サイト
      item_scraping(item_url)
      @item.company = "テスト用サイト"
      @i = rand(0..1)
      if @i == 0
        @item.save
        current_user.want(@item)
        flash[:success] = "商品を追加しました" 
      else
        flash[:warning] = "商品を追加できませんでした"
      end
      redirect_to user_path(current_user)
    else
      flash[:danger] = "商品を追加できませんでした" 
      redirect_to user_path(current_user)
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
  
  def update_price
    ##各社の商品検索APIを呼び出す
    if @item.company == "Yahoo!"
      #Yahoo!
      begin
        yahoo_application_id = ENV['YAHOO_APPID']
        yahoo_url = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemLookup"
        url = yahoo_url + "?appid=" + yahoo_application_id + "&itemcode=" + @item.code + "&image_size=132"
        result = JSON.parse(open(url).read, symbolize_names: true)
        @item = Item.new(read_yahoo_itemLookup_update(result))
        @i = 0
      rescue Mechanize::ResponseCodeError
        return @i = 1
      end
    elsif @item.company == "楽天"
      #楽天
      begin
        results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
        @item = Item.new(read_rakuten(results.first))
        @i = 0
      rescue Mechanize::ResponseCodeError
        return @i = 1
      end
    elsif @item.company == "Farfetch"
      #Farfetch
      if Item.find_by(code: @item.code)
        #2回目以降
        item_scraping_continue(@item)
      else
        #初回登録時
        item_url = @item.url
        item_scraping(item_url)
      end
    end
    return @i
  end
  
  def item_scraping(item_url)
    #初回登録時
    @item = Item.new
    
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Mozilla'
    url = item_url
    
    begin
      #Item.first
      page = agent.get(url)
    rescue Mechanize::ResponseCodeError
      return @i = 1
    end

    #初回登録時
    sleep(5)
    #商品名
    @item.name = page.search('//*[@id="slice-pdp"]/div/div[2]/div[3]/div[2]/span').text

    #code情報
    @item.code = "Farfetch" + "_" + @item.name

    sleep(5)
    #価格取得
    itemPrice = page.search('//*[@id="slice-pdp"]/div/div[2]/div[3]/div[3]/span/strong').text
    
    if itemPrice != ""
      @item.price = itemPrice.delete("¥").delete(",").strip.to_i
    else
      return @i = 1
    end
    
    #URL
    #Webスクレイピング設定時に入力してもらうので再取得不要
    @item.url = item_url

    #会社名
    #Farfetchに設定
    @item.company = "Farfetch"
    
    sleep(5)
    #画像URL
    #@item.image_url = page.search("//*[contains(@class,'_5a7352')]/img").attribute('src').value

    value = page.search("//*[contains(@class,'_5a7352')]/img").attribute('src').value

    if value == nil
      #Item.first
      p "画像取得に失敗しました"
        @item.image_url = ""
    else
      @item.image_url = value
    end

    #return @item
  end

  def item_scraping_continue(item)
    #2回目以降
    @item = Item.new
    
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Mozilla'
    url = item.url
    
    begin
      page = agent.get(url)
    rescue Mechanize::ResponseCodeError
      return @i = 1
    end

    #商品名
    @item.name = item.name

    #code情報
    @item.code = item.code

    #価格取得
    itemPrice = page.search('//*[@id="slice-pdp"]/div/div[2]/div[3]/div[3]/span/strong').text

    if itemPrice != ""
      @item.price = itemPrice.delete("¥").delete(",").strip.to_i
    else
      return @i = 1
    end
  
    #URL
    #Webスクレイピング設定時に入力してもらうので再取得不要
    @item.url = item.url

    #会社名
    #Farfetchに設定
    @item.company = "Farfetch"
    
    sleep(5)
    #画像URL
    @item.image_url = item.image_url

    return @item
  end
end
