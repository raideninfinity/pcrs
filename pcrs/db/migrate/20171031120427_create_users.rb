class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name, :null => false, :limit => 64
      t.string :password, :null => false, :limit => 32
	    t.date :dob, :null => false
	    t.string :email, :null =>false, :limit => 255
      t.decimal :credits, :null => false
      t.timestamps
    end
  end
end