class CreateOwnerships < ActiveRecord::Migration[5.0]
  def change
    create_table :ownerships do |t|
      t.references :user, foreign_key: true
      t.references :item, foreign_key: true

      t.timestamps

      t.index [:user_id, :item_id], unique: true
    end
  end
end
