class Time
  def super_parse(value)
    answer = nil
    begin 
      self.parse
    rescue
      year,month,day,hour,minute,second = value.split(" ")
      answer = Time.parse("#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}")
    end
    return answer
  end
end