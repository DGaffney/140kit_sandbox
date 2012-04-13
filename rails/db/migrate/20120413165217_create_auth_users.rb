class CreateAuthUsers < ActiveRecord::Migration
  def change
    create_table :auth_users do |t|
      t.string :screen_name
      t.string :password

      t.timestamps
    end
  end
end
