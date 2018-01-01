class User < ApplicationRecord
	before_save { self.email.downcase! }
	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 },
										format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
										uniqueness: { case_sensitive: false }

	has_many :ownerships
	has_many :ownership_items, through: :ownerships, source: :item

	has_secure_password
	
	#お気に入り登録用メソッド
	def want(item)
		self.ownerships.find_or_create_by(item_id: item.id)
	end
	
	def unwant(item)
		item = self.ownerships.find_by(item_id: item.id)
		item.destroy if item
	end
	
	def want?(item)
		self.ownership_items.include?(item)
	end
end
