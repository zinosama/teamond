class CreateShoppers < ActiveRecord::Migration
  def change
    create_table :shoppers do |t|

      t.timestamps null: false
    end
  end
end
