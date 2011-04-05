class Graph
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :unique_index => [:unique_graph], :index => [:title_graph]
  property :style, String, :unique_index => [:unique_graph], :index => [:style_graph]
  property :year, Integer, :unique_index => [:unique_graph], :index => [:year_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :year_month_date_hour, :year_month_date, :year_month, :year]
  property :month, Integer, :unique_index => [:unique_graph], :index => [:month_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :month_date_hour_graph, :month_date_graph, :year_month_date_hour, :year_month_date, :year_month, :month_date_hour, :month_date, :month]
  property :date, Integer, :unique_index => [:unique_graph], :index => [:date_graph, :year_month_date_hour_graph, :year_month_date_graph, :month_date_hour_graph, :date_hour_graph, :month_date_graph, :year_month_date_hour, :year_month_date, :month_date_hour, :month_date, :date_hour, :date]
  property :hour, Integer, :unique_index => [:unique_graph], :index => [:hour_graph, :year_month_date_hour_graph, :month_date_hour_graph, :date_hour_graph, :year_month_date_hour, :month_date_hour, :date_hour, :hour]
  property :written, Boolean, :default => false
  property :time_slice, Time, :unique_index => [:unique_graph], :index => [:time_slice_graph]
  has n, :graph_points
  has n, :edges
  belongs_to :analysis_metadata, :unique_index => [:unique_edge], :index => [:curation_id_analysis_metadata_id, :analysis_metadata_id]
  belongs_to :curation, :unique_index => [:unique_graph], :index => [:curation_id_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :month_date_hour_graph, :month_date_graph, :date_hour_graph, :year_graph, :month_graph, :date_graph, :hour_graph, :curation_id_analysis_metadata_id]
  
  def folder_name
    if time_slice
      time_slice.strftime("%Y/%m/%d/%H/%M/%S")
    elsif year || month || date || hour
      [year,month,date,hour].compact.join("/")
    else
      ""
    end
  end

  def sanitize_points(graph_points)
    Pretty.pretty_up_labels(self, graph_points)
  end
end