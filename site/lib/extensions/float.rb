class Float
    alias_method :round_orig, :round
    def round(n=0)
        (self * (10.0 ** n)).round_orig * (10.0 ** (-n))
    end
    
    def zero_decimals
      return (self.to_i-self) == 0
    end
    
end