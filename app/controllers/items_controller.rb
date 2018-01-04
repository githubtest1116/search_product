class ItemsController < ApplicationController
  def new
    @items = []
    
    @keyword = params[:keyword]
    
    if @keyword.present?
      #楽天
      results = RakutenWebService::Ichiba::Item.search({
        keyword: @keyword,
        imageFlag: 1,
        hits: 20,
      })
      results.each do |result|
        item = Item.find_or_initialize_by(read_rakuten(result))
        @items << item

      #Amazon
      #results = 
      #results.each do |result|
      #  item = Item.find_or_initialize_by(read_amazon(result))
      #  @items << item

      #Yahoo
      #results = 
      #results.each do |result|
      #  item = Item.find_or_initialize_by(read_yahoo(result))
      #  @items << item

      end
    end
  end
  
  def create
    @item = Item.find_by(code: params[:item_code])
    results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
    @item = Item.new(read_rakuten(results.first))
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

    @graph_data = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '価格推移')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)
      f.series(name: '価格推移', data: yAxis_data, type: 'spline')
      
      f.yAxis(title: {text: '円'})
    end
  end

  private
end
