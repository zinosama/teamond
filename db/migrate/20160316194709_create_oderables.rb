class CreateOderables < ActiveRecord::Migration
  def change
    create_table :oderables do |t|
    	t.integer :buyable_id
    	t.string :buyable_type

    	t.integer :ownable_id
    	t.string :ownable_type

    	t.decimal :unit_price
    	t.integer :quantity

      t.timestamps null: false
    end
  end
end
