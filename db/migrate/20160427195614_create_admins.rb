class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
    	t.references :user, index: true
    	
      t.timestamps null: false
    end
  end
end
