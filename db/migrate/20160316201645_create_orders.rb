class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.decimal :total
      t.boolean :paid, default: false	
      t.integer :payment_method
      t.string :payment_id

      t.string :recipient_name
      t.string :recipient_phone
      t.string :recipient_wechat
    	
      t.references :user, index:true
      t.references :locations_time, index: true

      t.timestamps null: false
    end
  end
end
