class CreateGraphPoints < ActiveRecord::Migration
  def change
    create_table :graph_points do |t|

      t.timestamps
    end
  end
end
