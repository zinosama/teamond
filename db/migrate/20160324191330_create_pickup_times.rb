class CreatePickupTimes < ActiveRecord::Migration
  def change
    create_table :pickup_times do |t|
    	t.integer :pickup_hour
    	t.integer :pickup_minute
    	t.integer :cutoff_hour
    	t.integer :cutoff_minute
    	
      t.timestamps null: false
    end
  end
end
