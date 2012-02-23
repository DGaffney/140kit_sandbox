class Array
  def sum
    self.compact.inject(0) { |s,v| s += v }
  end
  
  def to_i
    self.collect{|x| x.to_i}
  end
  
  def to_f
    self.collect{|x| x.to_i}
  end
  
  def frequencies
    new_val = {}
    self.each do |s|
      elem = s.to_s
      new_val[elem].nil? ? new_val[elem]=1 : new_val[elem]+=1
    end
    return new_val
  end
  
  def chunk(pieces=2)
    len = self.length
    return [] if len == 0
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end
  
  def repack
    set = []
    self.each do |slice|
      set<<slice
      yield set
    end
  end
  
  def centroid
    dimensions = self.flatten
    x_cent = (x_vals = 1.upto(dimensions.length).collect{|x| dimensions[x] if x.even?}.compact).sum/x_vals.length
    y_cent = (y_vals = 1.upto(dimensions.length).collect{|y| dimensions[y] if !y.even?}.compact).sum/y_vals.length
    return x_cent, y_cent
  end
  
  def area
    side_one = (self[0].to_f-self[2].to_f).abs
    side_two = (self[1].to_f-self[3].to_f).abs
    return side_one*side_two
  end
  
  def all_combinations(length_range=1..self.length)
    permutations = []
    length_range.max.downto(length_range.min) do |length|
      self.permutation(length).each do |perm|
        permutations << perm.sort if !permutations.include?(perm.sort)
      end
    end
    return permutations
  end
end