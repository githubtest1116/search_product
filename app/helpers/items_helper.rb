module ItemsHelper
	def register?(item)
		result = Item.find_by(code: item.code)
		
		if result
			return true
		else
			return false
		end
	end
end
