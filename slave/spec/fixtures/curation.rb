Curation.fixture {{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => [true,false][rand(2)],
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => false
}}
Curation.fixture(:finished){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => true,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => false
}}
Curation.fixture(:single){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => true,
  :analyzed => [true,false][rand(2)],
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => false
  
}}
Curation.fixture(:multiple){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => false,
  :analyzed => [true,false][rand(2)],
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => false
}}
Curation.fixture(:archived){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => [true,false][rand(2)],
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:finished_archived){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => true,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:finished_archived_single){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => true,
  :analyzed => true,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:finished_archived_multiple){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => false,
  :analyzed => true,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:unfinished){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => false,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => false
}}
Curation.fixture(:unfinished_archived){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => [true,false][rand(2)],
  :analyzed => false,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:unfinished_archived_single){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => true,
  :analyzed => false,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
Curation.fixture(:unfinished_archived_multiple){{
  :name            => /\w+/.gen,
  :researcher_id   => (researcher = Researcher.pick).id,
  :single_dataset => false,
  :analyzed => false,
  :created_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)).days+rand(86400),
  :updated_at => researcher.created_at+rand(((Time.now-researcher.created_at)/60/60/24)+1).days+rand(86400),
  :archived => true
}}
