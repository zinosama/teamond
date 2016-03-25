class CreatePickupLocations < ActiveRecord::Migration
  def change
    create_table :pickup_locations do |t|
    	t.string :name
    	t.string :address
    	t.string :description
    	
    	t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end
