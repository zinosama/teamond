class CreateMilkteaOrderables < ActiveRecord::Migration
  def change
    create_table :milktea_orderables do |t|
    	t.integer :sweet_scale
    	t.integer :temp_scale
    	t.integer :size

    	t.references :milktea, index: true

      t.timestamps null: false
    end
  end
end
