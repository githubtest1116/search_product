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
  
  def show
    @item = Item.find(params[:id])

    #横軸
    xAxis_categories = ['2013-11-09', '2013-11-10', '2013-11-11', '2013-11-12']

    #横軸の間隔
    tickInterval = 1
    
    #縦軸
    data = [120, 80, 90, 150]
    
    @graph_data = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '価格推移')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)
      f.series(name: '価格推移', data: data, type: 'spline')
    end




  end

  private
end
