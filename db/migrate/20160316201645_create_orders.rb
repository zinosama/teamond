class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.decimal :total
      t.integer :payment_status, default: 0	
      t.integer :payment_method
      t.string :payment_id
      t.string :refund_id

      t.integer :fulfillment_status, default: 0
      t.integer :satisfaction, default: 0
      t.string :issue
      t.string :solution

      t.string :recipient_name
      t.string :recipient_phone
      t.string :recipient_wechat
    	
      t.references :user, index:true
      t.references :locations_time, index: true

      t.timestamps null: false
    end
  end
end
