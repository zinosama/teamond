class CreateDishCategories < ActiveRecord::Migration
  def change
    create_table :dish_categories do |t|
    	t.string :name, null: false
    	t.boolean :active, default: false
    	
      t.timestamps null: false
    end
  end
end
