class CreateAdminLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_logs do |t|
	  t.references :admin, foreign_key: true, :null => false 
      t.string :ip, :null => false 
      t.string :action_name, :null => false , :limit => 255
      t.string :action_details, :null => false, :limit => 10000 
      t.timestamps
    end
  end
end
