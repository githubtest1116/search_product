class Item < ApplicationRecord
	validates :code, presence: true, length: { maximum: 255 }
	validates :name, presence: true, length: { maximum: 255 }
	validates :price, presence: true, length: { maximum: 255 }
	validates :url, presence: true, length: { maximum: 255 }
	validates :image_url, presence: true, length: { maximum: 255 }
	
	def want?
		self.find_by(code: @item.code)
	end
	
<<-PAGE	  
  def want(item)
    
  end
  
  def unwant(item)
  end
PAGE
end
