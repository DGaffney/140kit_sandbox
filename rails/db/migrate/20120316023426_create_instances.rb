class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :instance_id
      t.string :hostname
      t.integer :pid
      t.boolean :killed
      t.string :instance_type
      t.datetime :updated_at
      t.string :image_url

      t.timestamps
    end
  end
end
