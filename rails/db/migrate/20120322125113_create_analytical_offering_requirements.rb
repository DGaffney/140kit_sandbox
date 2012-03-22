class CreateAnalyticalOfferingRequirements < ActiveRecord::Migration
  def change
    create_table :analytical_offering_requirements do |t|

      t.timestamps
    end
  end
end
