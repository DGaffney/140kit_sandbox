namespace :import do
  require File.dirname(__FILE__)+'/../utils/sh'
  
  desc "Migrate the database up from current location to either specified migration or to latest"
  task :files => :environment do
    researcher = load_researcher
    puts "What type of curation will this be? (Can choose from: #{Dataset.scrape_types.inspect})"
    answer = Sh::clean_gets
    while !Dataset.scrape_types.include?(answer)
      puts "Sorry, that wasn't one of the options. Type the exact name please."
      answer = Sh::clean_gets
    end
    dataset = Dataset.new
    dataset.scrape_type = answer
    clean_params = validate_params(answer)
    dataset.params = clean_params
    if dataset.scrape_type != "import"
      puts "How long would you like to have this collection run? (Enter in number of seconds. I know, that's annoying.)"
      answer = Sh::clean_gets
      while answer.to_i==0
        puts "Sorry, we couldn't parse that value. Just numbers, please, you know, like '300'."
        answer = Sh::clean_gets
      end
      dataset.params = dataset.params+",#{answer}"
    end
    dataset.save
    if dataset.scrape_type == "import"
      importer_task = ImporterTask.new
      importer_task.file_location = dataset.params
      importer_task.dataset_id = dataset.id
      importer_task.type = File.file?(dataset.params) ? "single_file" : "batch_folder"
      importer_task.researcher_id = researcher.id
      importer_task.save!
    end
    curation = create_curation(dataset, researcher)
    select_analysis_metadata(curation)
  end
end
