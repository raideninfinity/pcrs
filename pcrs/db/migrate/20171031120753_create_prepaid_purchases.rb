class CreatePrepaidPurchases < ActiveRecord::Migration[5.1]
  def change
    create_table :prepaid_purchases do |t|
      t.references :user, foreign_key: true, :null => false 
      t.references :prepaid_code, foreign_key: true, :null => false 
      t.decimal :purchase_price, :null => false, precision: 10, scale: 2 
      t.timestamps
    end
  end
end
