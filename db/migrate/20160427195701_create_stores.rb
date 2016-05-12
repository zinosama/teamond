class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
    	t.string :name, null: false
    	t.string :phone, null: false
    	t.string :owner, null: false
    	
    	t.string :email
    	t.string :website

    	t.string :address, null: false
    	t.decimal :lat, null: false
    	t.decimal :long, null: false

    	t.boolean :active, default: false, null: false

      t.timestamps null: false
    end
  end
end
