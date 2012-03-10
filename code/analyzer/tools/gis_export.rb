class GisExport < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id)
    curation = Curation.first({:id => curation_id})
    model = model.classify.constantize rescue nil
    FilePathing.tmp_folder(curation, self.underscore)
    FilePathing.file_init("gis_export.csv")
    self.query_to_csv(curation)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize_work(curation)
  end

  def self.query_to_csv(curation, filename="/gis_export.csv", path=ENV['TMP_PATH'])
    first = true
    keys = ["twitter_id", "text", "created_at", "lat", "lon", "full_name", "geo_id", "country", "street_address", "locality", "iso3", "postal_code", "language", "source", "geo_type"]
    limit = 1000
    offset = 0
    Sh::mkdir(path)
    csv = CSV.open(path+filename, "w")
    records = DataMapper.repository.adapter.select("select tweets.twitter_id as twitter_id ,tweets.text as text,tweets.created_at as created_at,tweets.lat as lat,tweets.lon as lon,geos.full_name as full_name,geos.geo_id as geo_id,geos.country as country,geos.street_address as street_address,geos.locality as locality,geos.iso3 as iso3,geos.postal_code as postal_code,tweets.language as language,tweets.source as source,coordinates.geo_type as geo_type from tweets join geos on geos.twitter_id = tweets.twitter_id join coordinates on coordinates.twitter_id = geos.twitter_id #{Analysis.conditions_to_mysql_query(Analysis.curation_conditional(curation)).gsub("dataset_id", "tweets.dataset_id")} and tweets.lat is not null group by tweets.twitter_id limit #{limit} offset #{offset}")
    while !records.empty?
      records.each do |row|
        if first
          csv << keys
          first = false
        end
        csv << keys.collect{|key| row.send(key)}
      end
      offset+=limit
      records = DataMapper.repository.adapter.select("select tweets.twitter_id as twitter_id ,tweets.text as text,tweets.created_at as created_at,tweets.lat as lat,tweets.lon as lon,geos.full_name as full_name,geos.geo_id as geo_id,geos.country as country,geos.street_address as street_address,geos.locality as locality,geos.iso3 as iso3,geos.postal_code as postal_code,tweets.language as language,tweets.source as source,coordinates.geo_type as geo_type from tweets join geos on geos.twitter_id = tweets.twitter_id join coordinates on coordinates.twitter_id = geos.twitter_id #{Analysis.conditions_to_mysql_query(Analysis.curation_conditional(curation)).gsub("dataset_id", "tweets.dataset_id")} and tweets.lat is not null group by tweets.twitter_id limit #{limit} offset #{offset}")
    end
    csv.close
  end

  def self.clear(am)
    self.remove_permanent_folder(am.curation.stored_folder_name)
    am.destroy
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, your raw CSV data for the #{curation.name} data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
