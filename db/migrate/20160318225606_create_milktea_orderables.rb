class CreateMilkteaOrderables < ActiveRecord::Migration
  def change
    create_table :milktea_orderables do |t|
    	t.integer :sweet_scale, null: false
    	t.integer :temp_scale, null: false
    	t.integer :size, null: false

    	t.references :milktea, index: true, null: false
    	t.references :orderable, index: true

      t.timestamps null: false
    end
  end
end
