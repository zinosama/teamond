class CreateAddonsOrderables < ActiveRecord::Migration
  def change
    create_table :addons_orderables do |t|
    	
    	t.references :milktea_orderable, index: true
    	t.references :milktea_addon, index: true

      t.timestamps null: false
    end
  end
end
