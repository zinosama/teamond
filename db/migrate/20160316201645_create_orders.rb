class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.decimal :total
    	t.integer :payment_method
    	t.string :payment_id
    	t.boolean :paid, default: false	

    	t.references :user, index:true

      t.timestamps null: false
    end
  end
end
