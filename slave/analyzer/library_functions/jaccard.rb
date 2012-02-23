class Jaccard
  
  def self.coefficient(control_text, reference_text)
    union, total = self.coefficient_factors(control_text, reference_text)
    return (union.length)/total.length.to_f
  end

  def self.coefficient_factors(control_text, reference_text)
    control_array = control_text.split(" ")
    reference_array = reference_text.split(" ")
    return (control_array&reference_array), ([control_array,reference_array].flatten)
  end
end