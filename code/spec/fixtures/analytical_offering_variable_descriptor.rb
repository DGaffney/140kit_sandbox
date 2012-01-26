AnalyticalOfferingVariableDescriptor.fix{{
  :name => /\w+/.gen[5..25],
  :description => /[:sentence:]/.gen[50..250],
  :position => unique{rand(100)},
  :kind => ["string","float","integer"][rand(3)],
  :analytical_offering_id => AnalyticalOffering.pick.id
}}