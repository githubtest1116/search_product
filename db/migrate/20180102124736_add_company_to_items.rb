class AddCompanyToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :company, :string
  end
end
