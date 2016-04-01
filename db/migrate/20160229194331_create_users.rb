class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :name, null: false
    	t.string :email, null: false
    	t.string :phone
        t.string :wechat
    	t.string :password_digest, null: false
    	t.string :remember_digest
    	t.index :email, unique: true

    	t.boolean :admin, default: false

    	t.string :activation_digest
    	t.boolean :activated, default: false
    	t.datetime :activated_at

        t.string :reset_digest
        t.datetime :reset_sent_at
        
      t.timestamps null: false
    end
  end
end
