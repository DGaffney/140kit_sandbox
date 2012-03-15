class AnalysisMetadata < ActiveRecord::Base
  self.table_name = "analysis_metadatum"
  belongs_to :curation
  belongs_to :analytical_offering
  
  def status
    if self.finished
      return "<a href='/analysis/#{self.curation.id}/#{self.id}'>Results</a>"
    elsif self.curation.status == "imported"
      return "Processing"
    else return "Waiting for Dataset to Complete"
    end
  end
end
