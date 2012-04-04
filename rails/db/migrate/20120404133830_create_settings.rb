class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :value
      t.string :name
      t.string :var_type

      t.timestamps
    end
  end
end
