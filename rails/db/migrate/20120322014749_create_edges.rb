class CreateEdges < ActiveRecord::Migration
  def change
    create_table :edges do |t|

      t.timestamps
    end
  end
end
