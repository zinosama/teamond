class CreatePickupTimes < ActiveRecord::Migration
  def change
    create_table :pickup_times do |t|
    	t.integer :pickup_hour, null: false
    	t.integer :pickup_minute, null: false
    	t.integer :cutoff_hour, null: false
    	t.integer :cutoff_minute, null: false
    	
      t.timestamps null: false
    end
  end
end
