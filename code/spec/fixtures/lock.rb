models = ["AnalysisMetadata", "AuthUser", "Dataset", "Curation", "Graph", "Mail", "Tweet", "User"]
Lock.fix{{
  :classname => models.shuffle.first,
  :with_id => models.to_class.pick,
  :instance_id => Digest::SHA1.hexdigest("#{/\w+/.gen[5..25]}")
}}