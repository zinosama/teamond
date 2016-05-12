class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
    	t.boolean :chief_liaison, default: false, null: false

    	t.references :store, index: true

      t.timestamps null: false
    end
  end
end
