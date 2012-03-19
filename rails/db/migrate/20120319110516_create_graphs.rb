class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|

      t.timestamps
    end
  end
end
