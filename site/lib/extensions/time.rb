class Time
  def self.ntp
    return self.at(self.now.to_f + TIME_OFFSET)
  end

  def gmt
    return to_time.gmtime
  end
  
  # def to_json(options = nil)
  #   return "Date(#{self.year},#{self.month-1},#{self.day},#{self.hour},#{self.min},#{self.sec})"
  # end
end