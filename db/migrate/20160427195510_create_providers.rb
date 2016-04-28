class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
    	t.references :store, index: true

      t.timestamps null: false
    end
  end
end
