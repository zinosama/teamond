class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.decimal :total, null: false
      t.integer :payment_status, default: 0	
      t.integer :payment_method, null: false
      t.string :payment_id
      t.string :refund_id

      t.integer :fulfillment_status, default: 0
      t.integer :issue_status, default: 0
      t.integer :satisfaction, default: 0
      t.string :issue
      t.string :solution
      t.string :note

      t.string :recipient_name, null: false
      t.string :recipient_phone, null: false
      t.string :recipient_wechat
    	
      t.references :user, index:true, null: false
      t.references :locations_time, index: true, null: false

      t.timestamps null: false
    end
  end
end
