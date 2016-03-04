class CreateMilkteaAddons < ActiveRecord::Migration
  def change
    create_table :milktea_addons do |t|
    	t.string :name
    	t.decimal :price

      t.timestamps null: false
    end
  end
end
