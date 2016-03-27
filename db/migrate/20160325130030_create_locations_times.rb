class CreateLocationsTimes < ActiveRecord::Migration
  def change
    create_table :locations_times do |t|
    	t.integer :day_of_week, index: true

    	t.references :pickup_time, index: true
    	t.references :pickup_location, index: true

      t.timestamps null: false
    end
  end
end
