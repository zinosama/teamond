class CreateAddonsOrderables < ActiveRecord::Migration
  def change
    create_table :addons_orderables do |t|
    	
    	t.references :milktea_orderable, index: true, null: false
    	t.references :milktea_addon, index: true, null: false

      t.timestamps null: false
    end
  end
end
