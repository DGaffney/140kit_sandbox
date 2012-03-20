class Array
  def sum
    return self.inject(0){|acc,i|acc +i}
  end

  def average
    return self.sum/self.length.to_f
  end

  def sample_variance
    avg=self.average
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
  
  def counts
    self.inject(Hash.new(0)) do |hash,element|
      hash[element] += 1
      hash
    end
  end

  def percentile(percentage=0.0)
    another_array = self.to_a.dup
    another_array.push(-1.0/0.0)                   # add -Infinity to be 0th index
    another_array.sort!
    another_array_size = another_array.size - 1    # disregard -Infinity
    r = percentage.to_f * (another_array_size - 1) + 1
    if r <= 1 then return another_array[1]
    elsif r >= another_array_size then return another_array[another_array_size]
    end
    ir = r.truncate
    fr = fraction? r
    another_array[ir] + fr*(another_array[ir+1] - another_array[ir])
  end

  # def percentile(percentile=0.0)
  #   if percentile == 0.0
  #     return self.first
  #     else
  #       return self ? self.sort[((self.length * percentile).ceil)-1] : nil
  #     end
  #   end
end