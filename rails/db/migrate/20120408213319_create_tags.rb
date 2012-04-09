class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :tag
      t.string :classname
      t.integer :with_id

      t.timestamps
    end
  end
end
