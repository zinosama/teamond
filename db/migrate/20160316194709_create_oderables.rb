class CreateOderables < ActiveRecord::Migration
  def change
    create_table :oderables do |t|
    	t.references :buyable, polymorphic: true, index: true
    	t.references :ownable, polymorphic: true, index: true

    	t.decimal :unit_price
    	t.integer :quantity

      t.timestamps null: false
    end
  end
end
