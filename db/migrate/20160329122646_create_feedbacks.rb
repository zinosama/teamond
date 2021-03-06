class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
    	t.string :title, null: false
    	t.string :message, null: false
    	t.string :email

      t.boolean :read, default: false
      t.boolean :responded, default: false

    	t.references :user, index: true, foreign_key: true
    	
      t.timestamps null: false
    end
  end
end
