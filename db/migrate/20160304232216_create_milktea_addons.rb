class CreateMilkteaAddons < ActiveRecord::Migration
  def change
    create_table :milktea_addons do |t|
    	t.string :name, null: false
    	t.decimal :price, null: false

      t.timestamps null: false
    end
  end
end
