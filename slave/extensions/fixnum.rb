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

end