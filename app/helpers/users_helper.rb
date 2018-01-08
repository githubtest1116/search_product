module UsersHelper
	def gravatar_url(user, options = { size: 80 })
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
		size = options[:size]
		"https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=mm"
	end
	
	def latest_price_display(item)
		results = Item.where(code: item.code)
		a = []
		
		results.each do |result|
			a << result.price.to_i
		end
		item_price = number_to_currency(a.last, :locale => 'ja')
		return item_price
	end
	
	def comparing_price(item)
		results = Item.where(code: item.code)
		a = []
		
		results.each do |result|
			a << result.price.to_i
		end
		
		a  = a.last(2)
		
		#初回登録時に比較用にデータを設定する
		if a.count == 1
			a << a[0]
		end
		
		if a[0] > a[1]
			#最新価格の方が安い場合
			return 0
		elsif a[0] < a[1]
			#最新価格の方が高い場合
			return 1
		end
	end
	
	#最安値を出すメソッド
	#このメソッドは使用していない。
	def lower_price_display(item)
		results = Item.where(code: item.code)
		a = []
		
		results.each do |result|
			a << result.price.to_i
		end
		
		#item_price = a.min
		item_price = number_to_currency(a.min, :locale => 'ja')
		#item_price = number_to_currency(a.min, :unit => "￥", :precision => 0)
		#item_price = number_to_currency(a.min)
		#binding.pry
		return item_price
	end
end
