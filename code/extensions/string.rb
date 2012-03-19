class String
  def classify
    if self.split(//).last == "s"
      if self.split(//)[self.split(//).length-3..self.split(//).length].join == "ies"
        camelize(self.split(//)[0..self.split(//).length-4].join("")+"y")
      else
        camelize(self.sub(/.*\./, '').chop)
      end
    else
      camelize(self.sub(/.*\./, ''))
    end
  end

  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
  
  def constantize
    return Object.const_defined?(self) ? Object.const_get(self) : Object.const_missing(self)
  end
  
  def to_class
    return self.classify.constantize
  end

end