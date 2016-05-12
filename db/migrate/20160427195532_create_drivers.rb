class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
    	t.string :nickname, default: "Steve DBD", null: false

    	t.string :vehicle_make
    	t.string :vehicle_model
    	t.string :vehicle_color
    	t.string :license_plate

    	t.boolean :active, default: false, null: false

    	t.decimal :lat
    	t.decimal :long

      t.timestamps null: false
    end
  end
end
