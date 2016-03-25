class CreatePickupTimes < ActiveRecord::Migration
  def change
    create_table :pickup_times do |t|
    	t.datetime :time
    	
      t.timestamps null: false
    end
  end
end
