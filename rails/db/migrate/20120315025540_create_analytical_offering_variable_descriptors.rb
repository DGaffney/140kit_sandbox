class CreateAnalyticalOfferingVariableDescriptors < ActiveRecord::Migration
  def change
    create_table :analytical_offering_variable_descriptors do |t|
      t.string :name
      t.text :description
      t.boolean :user_modifiable
      t.integer :position
      t.string :kind
      t.integer :analytical_offering_id

      t.timestamps
    end
  end
end
