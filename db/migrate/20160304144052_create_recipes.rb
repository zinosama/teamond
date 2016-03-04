class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
    	t.string :name
    	t.string :description
    	t.string :image
    	
    	t.decimal :price

    	t.string :type

    	t.references :recipe_category, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
