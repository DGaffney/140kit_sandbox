class CreateAnalyticalOfferings < ActiveRecord::Migration
  def change
    create_table :analytical_offerings do |t|
      t.string :title
      t.text :description
      t.string :function
      t.boolean :rest
      t.string :created_by
      t.string :created_by_link
      t.boolean :enabled
      t.string :language
      t.string :access_level
      t.string :source_code_link

      t.timestamps
    end
  end
end
