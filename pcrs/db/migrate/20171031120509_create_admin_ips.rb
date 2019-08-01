class CreateAdminIps < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_ips do |t|
	  t.string :ip, :null => false	
      t.timestamps
    end
  end
end