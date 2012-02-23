class Fixnum
  
  def days
    return self*60*60*24
  end
  
  def day
    return days
  end
  
  def weeks
    return self*60*60*24*7
  end
  
  def week
    return weeks
  end

  def generalized_time_factor
    if self < 60
      #one second
      return 1
    elsif self < 3600
      #one minute
      return 60
    elsif self < 86400
      #one hour
      return 3600
    elsif self < 604800
      #one day
      return 86400
    elsif self < 11536000
      #one week
      return 604800
    else 
      #four weeks
      return 2419200
    end
  end

   
  def to_bool
    return self > 0 ? true : false
  end

  def humanized_length
    length = self
    humanized_length = ""
    weeks = length/604800
    if weeks > 0
      length -= weeks*604800
      humanized_length += weeks == 1 ? "#{weeks} week, " : "#{weeks} weeks, "
    end
    days = length/86400
    if days > 0
      length -= days*86400
      humanized_length += days == 1 ? "#{days} day, " : "#{days} days, "
    end
    hours = length/3600
    if hours > 0
      length -= hours*3600
      humanized_length += hours == 1 ? "#{hours} hour, " : "#{hours} hours, "
    end
    minutes = length/60
    if minutes > 0
      length -= minutes*60
      humanized_length += minutes == 1 ? "#{minutes} minute, " : "#{minutes} minutes, "
    end
    seconds = length
    if seconds > 0 
      length -= minutes*60
      humanized_length += seconds == 1 ? "#{seconds} second, " : "#{seconds} seconds, "      
    end
    humanized_length.chop!.chop! if !humanized_length.empty? && !humanized_length.nil?
    humanized_length
  end
end