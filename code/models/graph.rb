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
  property :time_slice, ZonedTime, :unique_index => [:unique_graph], :index => [:time_slice_graph]
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
    
  #methods for generating API views
  
  def google_json_column_declarations(x_class, y_class, y_label="Frequency")
    return {:cols => [{:id => self.title, :label => self.title.to_capitals, :type => x_class}, {:id => y_label.underscore.gsub(" ", "_"), :label => y_label, :type => y_class}], :rows => []}
  end
  
  def graph_points_to_google_json(json, x_class, y_class)
    graph_points.sort{|x, y| x.label.to_i<=>y.label.to_i}.each do |graph_point|
      x_val = resolve_val_for_class(x_class, graph_point.label)
      y_val = resolve_val_for_class(y_class, graph_point.value)
      json[:rows] << {:c => [{:v => x_val}, {:v => y_val}]}
    end
    json
  end
  
  def resolve_val_for_class(class_type, value)
    case class_type
    when "string"
      return value.empty? ? "Not Reported" : value
    when "number"
      return value.empty? ? 0 : (value.to_f.zero_decimals ? value.to_i : value.to_f.round(3))
    when "date"
      return value.empty? ? Time.now : (Time.parse(value) rescue Time.now)
    when "datetime"
      return value.empty? ? Time.now : (Time.parse(value) rescue Time.now)
    else
      return value
    end
  end

end