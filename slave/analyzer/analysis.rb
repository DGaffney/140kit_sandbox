class Analysis
  
  require File.dirname(__FILE__)+"/analysis_flow"
  require File.dirname(__FILE__)+"/dependencies"
  `ls #{File.dirname(__FILE__)}/library_functions/`.split.each {|f| require "#{File.dirname(__FILE__)}/library_functions/#{f}"}
  
  AnalyticalOffering.all.each do |ao|
    #here is where we come up with magic for running the other languages.
    #probably, it will just be something we omit entirely, unless there 
    #is some way to plug in a language binding over to ruby. When it's 
    #not ruby we just sh the function name, passing in the correct vars - 
    #it would have to either return structured output with a partnered 
    #ruby function to interpret and save, or make it's own mysql connection 
    #and save (may get ugly with lots of connections outside our system....)
    case ao.language
    when "ruby"
      require "#{File.dirname(__FILE__)}/tools/#{ao.function}.rb"
    end
  end
  
  def self.mean(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    if "datetime".include?(self.data_type(class_name, attribute))
      query = "select #{attribute} from #{class_name.pluralize}"
      query += self.where(parameters)
      query += ";"
      result = Environment.db.query(query)
      results = []
      1.upto(result.num_rows) {|i| results << SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1].to_f}
      return nil if results.length == 0
      mean = results.sum / results.length
      return Time.at(mean)
    else
      query = "select avg(#{attribute}) from #{class_name.pluralize}"
      query += self.where(parameters)
      query += ";"
      result = Environment.db.query(query)
      return SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1]
    end
  end
  
  def self.frequency_hash(class_name, attribute, parameters={})
    query = "select count(*) as frequency, #{attribute} from #{class_name.pluralize}"
    if parameters.class == Hash && !parameters.empty?
      query += self.where(parameters)
    elsif parameters.class == String
      query += parameters
    end
    query += " group by #{attribute} order by count(*) desc;"
    objects = Database.spooled_result(query)
    yield objects
  end
  
  def self.mode(class_name, attribute, parameters={})
    histogram = self.frequency_hash(class_name, attribute, parameters)
    histogram = histogram.sort {|a,b| b[1] <=> a[1]}
    results = histogram.select {|r| r[1] == histogram[0][1]}
    hash = {}
    results.each {|r| hash[r[0]] = r[1]}
    return hash
  end
  
  def self.median(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select #{attribute} from #{class_name.pluralize}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    results = []
    1.upto(result.num_rows) {|i| results << SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1]}
    return nil if results.length == 0
    return results[0] if results.length == 1
    results.sort!
    if "datetime".include?(results[0].class.to_s.downcase)
      return results.length.odd? ? results[results.length/2] : Time.at((results[results.length/2].to_f + results[results.length/2-1].to_f) / 2.0)
    else
      return results.length.odd? ? results[results.length/2] : (results[results.length/2].to_f + results[results.length/2-1].to_f) / 2.0
    end
  end
  
  def self.std_dev(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float], class_name, attribute)
    query = "select std(#{attribute}) from #{class_name.pluralize}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.variance(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float], class_name, attribute)
    query = "select variance(#{attribute}) from #{class_name.pluralize}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.max(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select max(#{attribute}) from #{class_name.pluralize}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.min(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select min(#{attribute}) from #{class_name.pluralize}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.where(parameters)
    query = " where"
    if !parameters.empty?
      parameters.each_pair {|k,v|
        if k.class == Array && k.length > 1
          if v.class == Array && v.length > 1
            k.each do |key|
              query += " and ("
              v.each do |val|
                query += " #{key} = #{SQLParser.prep_attribute(val)} or "
              end
              query.chop!.chop!.chop!.chop!
              query += ")"
            end
          else
            query = " and ("
            k.each do |key|
              query += " #{key} = #{SQLParser.prep_attribute(v)} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          end
        else
          if v.class == Array && v.length > 1
            query += " and ("
            v.each do |val|
              query += " #{k} = #{SQLParser.prep_attribute(val)} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          else
            query += " and #{k} = #{SQLParser.prep_attribute(v)} "
          end
        end
      }
    end
    query_clean = query.scan(/^\ *(where) \w* (.*)/)
    query = " "+query_clean[0][0]+" "+query_clean[0][1]
    return query
  end
  
  def self.valid_type?(valid_types, class_name, attribute)
    type = self.data_type(class_name, attribute)
    valid_types.collect! {|t| t.to_s.downcase}
    return valid_types.include?(type) ? true : false
  end
  
  def self.data_type(class_name, attribute)
    result = Environment.db.query("select #{attribute} from #{class_name.pluralize} limit 1")
    hash = result.fetch_hash
    return nil if hash.nil?
    return SQLParser.type_attributes(hash, result).to_a.flatten[1].class.to_s.downcase
  end
  
  def self.curation_conditional(curation)
    conditional = {}
    conditional[:dataset_id] = curation.datasets.collect{|d| d.id}
    return conditional
  end

  def self.time_conditional(time_variable, datetime, granularity)
    case granularity
    when "hour"
      return "#{time_variable} >= cast('#{datetime}:00:00' as datetime) and #{time_variable} <= cast('#{datetime}:59:59' as datetime)"
    when "date"
      return "#{time_variable} >= cast('#{datetime} 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime} 23:59:59' as datetime)"
    when "month"
      month = datetime.split("-").last.to_i
      year = datetime.split("-").first.to_i
      return "#{time_variable} >= cast('#{datetime}-01 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime}-#{U.month_days(month, year)} 23:59:59' as datetime)"
    when "year"
      return "#{time_variable} >= cast('#{datetime}-01-01 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime}-12-31 23:59:59' as datetime)"
    end
  end

  def self.hashes_to_csv(hash_array, file_name, path=$w.tmp_path)
    raise "Temp Folder not declared" if $w.tmp_path.nil?
    FasterCSV.open(path+file_name, "w") do |csv|
      keys = hash_array.first.keys
      csv << keys
      hash_array.each do |row|
        csv << keys.collect{|key| row[key]}
      end
    end
  end
  
  def self.proper_access_level(researcher_level, analysis_level)
    access_levels = ["User", "Private Researcher", "Commercial Account", "Admin"]
    return access_levels.index(researcher_level) >= access_levels.index(analysis_level)
  end
end