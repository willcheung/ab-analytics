require "statistics2"

module Stats
  
  def self.zstat(value, control_value, total_value, sample_size, control_sample_size)
    (value-control_value)/self.stdev(total_value, sample_size, control_sample_size)
  end
  
  def self.stdev(value, sample_size, control_sample_size)
    v = Math.sqrt((value*(1-value)*((1/sample_size)+(1/control_sample_size)))**2) # Should not square this, b/c value can't be negative
    Math.sqrt(v)
  end
  
  def self.pvalue(value)
    if value < 0
      Statistics2.normaldist(value)*2
    else
      (1-Statistics2.normaldist(value))*2
    end
  end
  
end