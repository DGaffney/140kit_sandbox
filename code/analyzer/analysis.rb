class Analysis

  require File.dirname(__FILE__)+"/dependencies"
  Sh::bt("ls #{File.dirname(__FILE__)}/library_functions/").split.each {|f| require "#{File.dirname(__FILE__)}/library_functions/#{f}"}
  
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
  
  def self.conditions_to_mysql_query(parameters)
    query = " "
    if !parameters.empty?
      parameters.each_pair {|k,v|
        if k.class == Array && k.length > 1
          if v.class == Array
            "#{k.join(" or ")} in ('#{v.join("', '")}')"
          else
            query += " (#{k.join(" or ").to_s}) = '#{v}' and "
          end
        elsif k.class == DataMapper::Query::Operator
          operator = k.operator == :gte ? ">=" : "<="
          field = k.target.to_s
          if v.class == Array
            query += "#{field} #{operator} ('#{v.join("', '")}') and "
          else
            query += " #{field} #{operator} '#{v}' and "
          end
        else
          if v.class == Array
            query += "#{k.to_s} in ('#{v.join("', '")}') and "
          else
            query += " #{k.to_s} = '#{v}' and "
          end
        end
      }
    end
    query = query.chop!.chop!.chop!.chop!
    return "where "+query
  end
  
  def self.curation_conditional(curation)
    conditional = {}
    conditional[:dataset_id] = curation.datasets.collect{|d| d.id}
    return conditional
  end

  def self.time_conditional(time_variable, datetime, granularity)
    case granularity
    when "hour"
      return {time_variable.to_sym.gt => Time.parse("#{datetime}:00:00"), time_variable.to_sym.lt => Time.parse("#{datetime}:59:59")} 
    when "date"
      return {time_variable.to_sym.gt => Time.parse("#{datetime} 00:00:00"), time_variable.to_sym.lt => Time.parse("#{datetime} 23:59:59")} 
    when "month"
      month = datetime.split("-").last.to_i
      year = datetime.split("-").first.to_i
      return {time_variable.to_sym.gt => Time.parse("#{datetime}-01 00:00:00"), time_variable.to_sym.lt => Time.parse("#{datetime}-#{U.month_days(month, year)} 23:59:59")} 
    when "year"
      return {time_variable.to_sym.gt => Time.parse("#{datetime}-01-01 00:00:00"), time_variable.to_sym.lt => Time.parse("#{datetime}-12-31 23:59:59")} 
    end
  end

end

module ActsAsReloadable;end