class CreateAnalyticalOfferingVariables < ActiveRecord::Migration
  def change
    create_table :analytical_offering_variables do |t|
      t.text :value
      t.integer :analysis_metadata_id
      t.integer :analytical_offering_variable_descriptor_id

      t.timestamps
    end
  end
end
