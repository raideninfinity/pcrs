class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :name,:null => false, :limit => 64
      t.string :password,:null => false, :limit => 32

      t.timestamps
    end
  end
end
