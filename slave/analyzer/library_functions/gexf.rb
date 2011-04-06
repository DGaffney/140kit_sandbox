module Gexf
  def self.header(mode="dynamic", default_edge_type="directed")
    %{<gexf xmlns="http://www.gexf.net/1.1draft"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.gexf.net/1.1draft
                             http://www.gexf.net/1.1draft/gexf.xsd"
      version="1.1">
  <graph mode="#{mode}" defaultedgetype="#{default_edge_type}">
    }
  end
  
  #attribute_declarations look like => {{:class => 'node', :mode => 'static'} => [{:id => name, :title => name, :type => type}]}
  def self.attribute_declarations(attribute_declarations)
    attribute_declaration_data = %{}
    attribute_declarations.each_pair do |attribute_declaration_header, attribute_declarations|
      attribute_declaration_data << self.attribute_declaration_header(attribute_declaration_header)
      attribute_declarations.each do |attribute_declaration|
        attribute_declaration_data << self.attribute_declaration(attribute_declaration)
      end
    end
    attribute_declaration_data << self.attribute_declaration_footer
  end

  #attribute_declaration_headers look like => {:class => ['node'||'edge'], :mode => ['static'||'dynamic']}
  def self.attribute_declaration_header(attribute_declaration_header)
    %{	<attributes#{attribute_declaration_header.collect{|k,v| " #{k}=\"#{v}\""}.to_s}>}
  end

  #attribute_declaration look like => {:id => name, :title => name, :type => type}  
  def self.attribute_declaration(attribute_declaration)
    attribute_declaration_data = "\n\t<attribute "
    attribute_declaration.each_pair do |k,v|
      k = k.to_s
      if k == "type"
        attribute_declaration_data << %{ #{k}="#{self.gexf_class(v)}" }
      else
        attribute_declaration_data << %{ #{k}="#{v}" }
      end
    end
    attribute_declaration_data << "/>"
  end
  
  def self.attribute_declaration(attribute)
    %{<attribute#{attribute.collect{|k,v| " #{k}=\"#{v}\""}.to_s}/>}
  end
    
  def self.attribute_declaration_footer
    "</attributes>"
  end
  
  def self.footer
    "  </graph>\n</gexf>"
  end

  def self.nodes(nodes)
    %{
      #{self.nodes_header}
      #{nodes.collect{|node| self.node(node)}}
      #{self.nodes_footer}
    }
  end
  
  def self.node(node)
    node_data = %{}
    metadata_keys = [:attributes, :slices]
    node_data << self.node_header(Hash[node.select{|k,v| !metadata_keys.include?(k)}])
    if node[:attributes] && !node[:attributes].empty?
      node_data << self.attributes_header
      node[:attributes].each do |attribute|
        node_data << self.attribute(attribute)
      end
      node_data << self.attributes_footer
    end
    if node[:slices] && !node[:slices].empty?
      node_data << self.slices_header
      node[:slices].each do |attribute|
        node_data << self.slice(attribute)
      end
      node_data << self.slices_footer
    end
    node_data << self.node_footer
  end
  
  def self.nodes_header
    "  <nodes>\n"
  end

  #node looks like => {:id => screen_name, :label => screen_name}
  def self.node_header(node)
    %{    <node#{node.collect{|k,v| " #{k}=\"#{v}\""}.to_s}>}
  end
  
  def self.node_footer
    "    </node>\n"
  end
  
  def self.nodes_footer
    "  </nodes>\n"
  end
  
  def self.edges(edges)
    %{
    #{self.edges_header}
    #{edges.collect{|edge| self.edge(edge)}}
    #{self.attribute_declaration_footer}
    }
  end
  
  def self.edge(edge)
    edge_data = %{}
    metadata_keys = [:attributes, :slices]
    edge_data << self.edge_header(Hash[edge.select{|k,v| !metadata_keys.include?(k)}])
    if edge[:attributes] && !edge[:attributes].empty?
      edge_data << self.attributes_header
      edge[:attributes].each do |attribute|
        edge_data << self.attribute(attribute)
      end
      edge_data << self.attributes_footer
    end
    if edge[:slices] && !edge[:slices].empty?
      edge_data << self.slices_header
      edge[:slices].each do |attribute|
        edge_data << self.slice(attribute)
      end
      edge_data << self.slices_footer
    end
    edge_data  << self.edge_footer
  end
  
  def self.edges_header
    "  <edges>\n"
  end
  
  #edge looks like => {:source => start_node, :target => :end_node, :start => start_time, :end => end_time, :weight => weight}
  def self.edge_header(edge)
    %{    <edge#{edge.collect{|k,v| " #{k}=\"#{v}\""}.to_s}>\n}
  end
  
  def self.edge_footer
    "    </edge>\n"
  end
  
  def self.edges_footer
    "  </edges>\n"
  end
  
  def self.attributes_header
    "      <attvalues>\n"
  end
  #attribute looks like => {:for => attribute_name, :value => value, :start => start_time, :end => end_time}
  def self.attribute(attribute)
    %{        <attvalue#{attribute.collect{|k,v| " #{k}=\"#{v}\""}.to_s}/>\n}
  end
  
  def self.attributes_footer
    "      </attvalues>\n"
  end
  
  def self.slices_header
    "      <slices>\n"
  end
  
  #slice looks like => {:start => start_time, :end => end_time}
  def self.slice(slice)
    %{        <slice#{slice.collect{|k,v| " #{k}=\"#{v}\""}.to_s}/>\n}
  end
  
  def self.slices_footer
    "      </slices>\n"
  end
  
  def self.gexf_class(ruby_class)
    classes = {"Fixnum" => "int", "Float" => "float", "Bignum" => "double", "Integer" => "int", "String" => "string", "TrueClass" => "bool", "FalseClass" => "bool", "NilClass" => "int"}
    return classes[ruby_class.to_s] || "int"
  end
  
  module Writer
    def self.initialize_temp_data(fs, graph, path=ENV['TMP_PATH'])
      File.delete(path+"/temp_node.gexf") if File.exists?(path+"/temp_node.gexf")
      File.delete(path+"/temp_edge.gexf") if File.exists?(path+"/temp_edge.gexf")
      File.delete(path+"/temp_header.gexf") if File.exists?(path+"/temp_header.gexf")
      self.generate_temp_header(fs, graph, path)
    end

    def self.generate_temp_header(fs, graph, path)
      header_data = File.open(path+"/temp_header.gexf", "a+")
      self.generate_header(fs, header_data)
      self.generate_attribute_declarations(fs, header_data)
    end

    def self.generate_temp_data(fs, edges, path=ENV['TMP_PATH'])
      node_data = File.open(path+"/temp_node.gexf", "a+")
      self.generate_nodes(fs, edges, node_data)
      edge_data = File.open(path+"/temp_edge.gexf", "a+")
      self.generate_edges(fs, edges, edge_data)
    end

    def self.finalize_temp_data(fs, path=ENV['TMP_PATH'])
      final_file = File.open(path+"/#{fs[:title]||"graph"}.gexf", "w+")
      final_file.write(File.read(path+"/temp_header.gexf"))
      final_file.write(File.read(path+"/temp_node.gexf"))
      final_file.write(File.read(path+"/temp_edge.gexf"))
      final_file.write(Gexf::footer)
      final_file.close
      File.delete(path+"/temp_node.gexf") if File.exists?(path+"/temp_node.gexf")
      File.delete(path+"/temp_edge.gexf") if File.exists?(path+"/temp_edge.gexf")
      File.delete(path+"/temp_header.gexf") if File.exists?(path+"/temp_header.gexf")
    end
    
    def self.generate_header(fs, file)
      mode = fs[:mode]||"dynamic"
      default_edge_type = fs[:default_edge_type]||"directed"
      file.write(Gexf::header(mode, default_edge_type))
    end

    def self.generate_attribute_declarations(fs, file)
      attribute_declarations = {}
      classes_for_attributes = {:statuses_count => Fixnum, :followers_count => Fixnum, :friends_count => Fixnum}
      modes_for_attributes = {:statuses_count => :static, :followers_count => :static, :friends_count => :static}
      fs[:node_attributes].each do |node_attribute|
        attribute_declarations[{:class => :node, :mode => modes_for_attributes[node_attribute]}] = [] if attribute_declarations[{:class => :node, :mode => modes_for_attributes[node_attribute]}].nil?
        attribute_declarations[{:class => :node, :mode => modes_for_attributes[node_attribute]}] << {:id => node_attribute, :title => node_attribute.to_s.split("_").collect{|w| w.capitalize}.join(" "), :type => classes_for_attributes[node_attribute]}
      end
      fs[:edge_attributes].each do |edge_attribute|
        attribute_declarations[{:class => :node, :mode => modes_for_attributes[edge_attribute]}] = [] if attribute_declarations[{:class => :node, :mode => modes_for_attributes[edge_attribute]}].nil?
        attribute_declarations[{:class => :node, :mode => modes_for_attributes[edge_attribute]}] << {:id => edge_attribute, :title => edge_attribute.to_s.split("_").collect{|w| w.capitalize}.join(" "), :type => classes_for_attributes[edge_attribute]}
      end
      file.write(Gexf::attribute_declarations(attribute_declarations))
    end

    def self.generate_nodes(fs, edges, file)
      node_names = edges.collect{|edge| [edge.start_node, edge.end_node]}.flatten.uniq
      node_names.each do |node_name|
        node = {:id => node_name, :label => node_name}.merge(self.generate_node_metadata(fs,node_name))
        file.write(Gexf::node(node))
      end
    end
  #edge looks like => {:source => start_node, :target => :end_node, :start => start_time, :end => end_time, :weight => weight}
    def self.generate_edges(fs, edges, file)
      start_node_names = edges.collect{|edge| edge.start_node}.flatten.uniq
      start_node_names.each do |start_node_name|
        edge_sets = self.group_edges_by_end_node(start_node_name, edges)
        edge_sets.each do |edge_set|
          edge_data = {:source => edge.start_node, :target => edge.end_node}.merge(self.generate_edge_metadata(fs, edge_set))
          file.write(Gexf::edge(edge_data))
        end
      end
    end

    #attribute looks like => {:for => attribute_name, :value => value, :start => start_time, :end => end_time}
    def self.generate_node_metadata(fs, node_name)
      attributes = {:attributes => []}
      fs[:node_attributes].each do |node_attribute|
        case node_attribute
        when :statuses_count
          attributes[:attributes] << {:for => :statuses_count, :value => User.first(:screen_name => node_name)&&User.first(:screen_name => node_name).statuses_count||-1}
        when :followers_count
          attributes[:attributes] << {:for => :followers_count, :value => User.first(:screen_name => node_name)&&User.first(:screen_name => node_name).followers_count||-1}
        when :friends_count
          attributes[:attributes] << {:for => :friends_count, :value => User.first(:screen_name => node_name)&&User.first(:screen_name => node_name).friends_count||-1}
        end
      end
      attributes
    end

    def self.generate_edge_metadata(fs, edge_set)
      attributes = self.calculate_weights(fs, edge_set)
      fs[:edge_attributes].each do |edge_attribute|
        # case edge_attribute
        # end
      end
      attributes
    end
    
    def self.calculate_weights(fs, edge_set)
      range_factor = fs[:total_range].to_i.generalized_time_factor
      weights = edge_set.collect{|edge| edge.time}.collect{|t| t.to_i/range_factor}.frequencies
      edge_data = {:attributes => [], :slices => []}
      #divide/multiply the range factor to normalize against rounding errors.
      edge_data[:start] = (edge_set.sort{|edge_a,edge_b| edge_a.time.to_i<=>edge_b.time.to_i}.first.time.to_i/range_factor)*range_factor
      edge_data[:end] = (edge_set.sort{|edge_a,edge_b| edge_a.time.to_i<=>edge_b.time.to_i}.last.time.to_i/range_factor)*range_factor
      weights.each_pair do |time, weight|
        edge_data[:attributes] << {:for => "weight", :value => weight, :start => time*range_factor, :end => time*range_factor+range_factor}
        edge_data[:slices] << {:start => time*range_factor, :end => time*range_factor+range_factor}
      end
      edge_data
    end
    
    def self.group_edges_by_end_node(start_node_name, edges)
      edge_sets = {}
      edges = edges.select{|edge| edge.start_node==start_node_name}
      edges.each do |edge|
        edge_sets[edge.end_node] = [] if edge_sets[edge.end_node].nil?
        edge_sets[edge.end_node] << edge
      end
      return edge_sets.values
    end
  end
end