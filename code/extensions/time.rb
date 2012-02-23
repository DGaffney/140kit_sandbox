class Time
  def self.ntp
    return self.at(self.now.to_f)
  end

  def gmt
    return to_time.gmtime
  end
end