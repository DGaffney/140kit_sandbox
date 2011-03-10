class DateTime
  def gmt
    return to_time.utc
  end
end
