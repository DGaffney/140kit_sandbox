AnalyticalOfferingVariableDescriptor.fix{{
  :name => /\w+/.gen[5..25],
  :description => /[:sentence:]/.gen[50..250],
  :position => rand(3),
  :kind => ["string","float","integer"][rand(3)],
  :analytical_offering_id => AnalyticalOffering.pick.id
}}