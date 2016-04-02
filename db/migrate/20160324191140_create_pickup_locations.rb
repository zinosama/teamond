class CreatePickupLocations < ActiveRecord::Migration
  def change
    create_table :pickup_locations do |t|
    	t.string :name, null: false
    	t.string :address, null: false
    	t.string :description
    	
    	t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end
