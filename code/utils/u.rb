module U
  API_RATE_LIMIT_URL = "http://twitter.com/account/rate_limit_status.json"
  def self.times_up?(time)
    return Time.now >= time ? true : false
  end
  
  def self.return_data(url, rate_limiting_request=true, verbose=false)
    puts "Grabbing data from url: #{url}" if verbose
    tries = 0
    rate_limit_data = nil
    if rate_limiting_request && (url!=API_RATE_LIMIT_URL||!url.include?("twitter.com"))
      while rate_limit_data.class != Hash
        begin
          rate_limit_data = JSON.parse(open(API_RATE_LIMIT_URL).read)
        rescue => e
          rate_limit_data = nil
          puts "CAN YOU SHOW ME A \"HAT WOBBLE\": #{e}" if verbose
          retry
        end
      end
      ttl = (rate_limit_data["reset_time_in_seconds"]-Time.now.to_i)
      hits_left = rate_limit_data["remaining_hits"]
      puts "#{hits_left} hits remaining; #{ttl} seconds remaining; sleeping for #{ttl/(hits_left+1).to_f} seconds." if verbose
      sleep((ttl/(hits_left+1).to_f).abs)
    end
    begin
      raw_data = open(url).read
    rescue => e
      puts e
      if !e.to_s.include?("401")
        if tries <= 3
          tries += 1
          retry
        end
      end
      return raw_data
    end
    return raw_data
  end  
  
  def self.month_days(month, year=nil)
    case month.to_i
    when 1
      return 31
    when 2
      if year%400 == 0
        return 28
      elsif year%100 == 0
        return 29
      elsif year%4 == 0
        return 28
      else return 29
      end
    when 3
      return 31
    when 4
      return 30
    when 5
      return 31
    when 6
      return 30
    when 7
      return 31
    when 8
      return 31
    when 9
      return 30
    when 10
      return 31
    when 11
      return 30
    when 12
      return 31
    end                                                                 
  end
end