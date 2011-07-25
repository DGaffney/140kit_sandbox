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
  
  def chart_type_for(graph)
    case graph.title
    when "tweets_language"
      "PieChart"
    else "LineChart"
    end
  end
  
  def options_for(graph)
    case graph.title
    when "tweets_language"
      "{title: 'Overview', titleX: 'Length', titleY: 'Average', height: 500, width:915, is3D: true, curveType: 'function', Vaxis: {minValue: 0.0}}"
    else
    end
  end
  
  #methods for generating API views
  def google_json_header(tqx)
    self.class.google_json_header(tqx)
  end
  
  def google_json_column_declarations
    "cols:[{id:\"#{self.title}\",label:\"#{self.title.to_capitals}\",type:'string'},{id:\"frequency\",label:\"Frequency\",type:'number'}],"    
  end
  
  def graph_points_to_google_json
    json = "rows:["
    graph_points.sort{|x, y| x.label.to_i<=>y.label.to_i}.each do |graph_point|
      json+="{c:[{v:'#{graph_point.label.empty? ? "Not Reported" : graph_point.label}',f:'Total Count for #{graph_point.label.empty? ? "Not Reported" : graph_point.label}'},"
      json+="{v:#{graph_point.value.to_f.round(3)}}]},"
    end
    json.chop!
    json+= "]"
  end
  
  def google_json_footer
    self.class.google_json_footer
  end
  
  def self.graphs_to_google_ready_hash(graphs=self.all)
    ordered_graph_sets = {}
    graph_point_sets = graphs.sort{|x,y| x.created_at.to_i<=>y.created_at.to_i}.collect{|graph| graph.graph_points.sort{|x, y| x.label.to_i<=>y.label.to_i}}
    graph_point_sets.each do |graph_points|
      graph_points.each do |graph_point|
        ordered_graph_sets[graph_point.label] = {} if ordered_graph_sets[graph_point.label].nil?
        ordered_graph_sets[graph_point.label][graph_point.graph_id.to_s] = graph_point.value
      end
    end
    return ordered_graph_sets
  end
  
  def self.google_json_footer
    "]}});"
  end
  
  def self.google_json_header(tqx)
    "google.visualization.Query.setResponse({version:'0.6',status:'ok',#{tqx},table:{"
  end
end