class CreatePrepaidCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :prepaid_codes do |t|
      t.string :code, :null => false, :limit => 255 
      t.string :pin, :limit => 255 
      t.references :prepaid_type, foreign_key: true, :null => false 
      t.references :admin, foreign_key: true, :null => false 
      t.timestamps
    end
  end
end
