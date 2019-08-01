class CreateReloadRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :reload_requests do |t|
      t.references :user, foreign_key: true, :null => false 
      t.string :transaction_id, :null => false, :limit => 255 
      t.string :transaction_type, :null => false 
      t.string :comments, :limit => 1000
      t.string :approved, :null => false, :limit => 16 
      t.references :admin, foreign_key: true
	    t.string :approve_comments, :limit => 1000
      t.datetime :approve_time
      t.decimal :approve_credits
      t.timestamps
    end
  end
end
