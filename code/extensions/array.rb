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

	def percentile(percentile=0.0)
	  if percentile == 0.0
	    return self.first
    else
      return self ? self.sort[((self.length * percentile).ceil)-1] : nil
    end
  end
end