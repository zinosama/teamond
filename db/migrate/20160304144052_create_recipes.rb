class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
    	t.string :name, null: false
    	t.string :description, null: false
    	t.string :image
    	
    	t.decimal :price, null: false

    	t.string :type, null: false
      t.boolean :active, default: false

    	t.references :dish_category, index: true, foreign_key: true
      t.references :store, index: true, null: false
      t.timestamps null: false
    end
  end
end
