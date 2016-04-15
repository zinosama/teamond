class CreateOrderables < ActiveRecord::Migration
  def change
    create_table :orderables do |t|
    	t.references :buyable, polymorphic: true, index: true
    	t.references :ownable, polymorphic: true, index: true

    	t.decimal :unit_price, null: false
    	t.integer :quantity, default: 1, null: false
    	t.integer :status, default: 0, null: false

      t.timestamps null: false
    end
  end
end
