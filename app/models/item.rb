class Item < ApplicationRecord
	validates :code, presence: true, length: { maximum: 255 }
	validates :name, presence: true, length: { maximum: 255 }
	validates :price, presence: true, length: { maximum: 255 }
	validates :url, presence: true, length: { maximum: 255 }
	validates :image_url, presence: true, length: { maximum: 255 }
	validates :company, presence: true, length: { maximum: 255 }

	has_many :ownerships
	has_many :users, through: :ownerships


<<-PAGE	
	def want?(item)
		self.find_by(code: @item.code)
	end

  def want(item)
    
  end
  
  def unwant(item)
  end
PAGE
end
