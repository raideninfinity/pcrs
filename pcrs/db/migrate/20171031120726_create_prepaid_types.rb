class CreatePrepaidTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :prepaid_types do |t|
      t.string :name, :null => false, :limit => 255 
      t.decimal :price, :null => false, precision: 10, scale: 2 
      t.integer :image_id, :null => false, :limit => 8
      t.timestamps
    end
  end
end
