module Graphml
  def self.header(key=rand(10000))
    %{<?xml version="1.0" encoding="UTF-8"?>\n<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \nxsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">\n\t<graph id="#{key}" edgedefault="directed">}
  end
  
  def self.attribute_declarations(attribute_declarations)
    attribute_declarations.collect{|attribute_declaration| self.attribute_declaration(attribute_declaration)}.join("")
  end
  
  #attribute looks like: {:id => name, :for => ["node"||"edge"], :attr_name => name, :attr_type => type}
  def self.attribute_declaration(attribute_declaration)
    attribute_declaration_data = "\n\t<key "
    attribute_declaration.each_pair do |k,v|
      k = k.to_s.gsub("_", ".")
      if k == "attr.type"
        attribute_declaration_data << %{ #{k}="#{self.graphml_class(v.to_s)}"}
      else
        attribute_declaration_data << %{ #{k}="#{v}"}
      end
    end
    attribute_declaration_data << " />"
  end
  
  def self.nodes(nodes)
    nodes.collect{|node| self.node(node)}
  end
  
  #nodes look like {:id => screen_name}
  def self.node(node)
    node_data = ""
    metadata_keys = [:attributes]
    non_metadata_node = Hash[node.select{|k,v| !metadata_keys.include?(k)}]
    if !node[:label].to_s.blank? && !node[:id].to_s.blank?
      if node[:attributes] && !node[:attributes].empty?
        node_data << %{\n\t\t<node #{non_metadata_node.collect{|k,v| " #{k}=\"#{v}\""}.join(" ")}>}
        node[:attributes].each do |attribute|
          node_data << self.attribute(attribute)
        end
        node_data << "\n\t\t</node>"
      else
        node_data << %{\n\t\t<node #{non_metadata_node.collect{|k,v| " #{k}=\"#{v}\""}.join(" ")}/>}
      end
    end
    node_data
  end

  def self.edges(edges)
    edges.collect{|edge| self.edge(edge)}
  end

  #edges look like: {:id => edge_id, :source => start_node, :target => end_node}  
  def self.edge(edge)
    edge_data = ""
    metadata_keys = [:attributes]
    non_metadata_edge = Hash[edge.select{|k,v| !metadata_keys.include?(k)}]
    if !edge[:source].to_s.blank? && !edge[:target].to_s.blank?
      if edge[:attributes] && !edge[:attributes].empty?
        edge_data << %{\n\t\t<edge#{non_metadata_edge.collect{|k,v| " #{k}=\"#{v}\""}.join(" ")}>}
        edge[:attributes].each do |attribute|
          edge_data << self.attribute(attribute)
        end
        edge_data << "\n\t\t</edge>"
      else
        edge_data << %{\n\t\t<edge#{non_metadata_edge.collect{|k,v| " #{k}=\"#{v}\""}.join(" ")}/>}
      end
    end
    edge_data
  end
    
  def self.attribute(attribute)
    attribute_data = %{}
    attribute_data << %{\n\t\t\t<data key="#{attribute[:for]}">#{attribute[:value]}</data>}
    attribute_data
  end
  
  def self.footer
    "\n\t</graph>\n</graphml>"
  end

  def self.graphml_class(ruby_class)
    classes = {"Fixnum" => "int", "Float" => "float", "Bignum" => "double", "Integer" => "int", "String" => "string", "TrueClass" => "bool", "FalseClass" => "bool", "NilClass" => "int"}
    return classes[ruby_class.to_s] || "int"
  end
  
  module Writer
    #where fs is a frequency set as defined in retweet_graphs, graph is a given graph object that data is worked from, and file is the entity being written to.
    def self.initialize_temp_data(fs, path=ENV['TMP_PATH'])
      File.delete(path+"/temp_node.graphml") if File.exists?(path+"/temp_node.graphml")
      File.delete(path+"/temp_edge.graphml") if File.exists?(path+"/temp_edge.graphml")
      File.delete(path+"/temp_header.graphml") if File.exists?(path+"/temp_header.graphml")
      self.generate_temp_header(fs, path)
    end

    def self.generate_temp_header(fs, path=ENV['TMP_PATH'])
      header_data = File.open(path+"/temp_header.graphml", "a+")
      self.generate_header(fs, header_data)
      self.generate_attribute_declarations(fs, header_data)
      header_data.close
    end

    def self.generate_temp_data(fs, edges, path=ENV['TMP_PATH'])
      node_data = File.open(path+"/temp_node.graphml", "a+")
      self.generate_nodes(fs, edges, node_data)
      node_data.close
      edge_data = File.open(path+"/temp_edge.graphml", "a+")
      self.generate_edges(fs, edges, edge_data)
      edge_data.close
    end

    def self.finalize_temp_data(fs, path=ENV['TMP_PATH'])
      final_file = File.open(path+"/#{fs[:title]||"graph"}.graphml", "w+")
      final_file.write(File.read(path+"/temp_header.graphml"))
      final_file.write(File.read(path+"/temp_node.graphml"))
      final_file.write(File.read(path+"/temp_edge.graphml"))
      final_file.write(Graphml::footer)
      final_file.close
      File.delete(path+"/temp_node.graphml") if File.exists?(path+"/temp_node.graphml")
      File.delete(path+"/temp_edge.graphml") if File.exists?(path+"/temp_edge.graphml")
      File.delete(path+"/temp_header.graphml") if File.exists?(path+"/temp_header.graphml")
    end
    
    def self.generate_header(fs, file)
      key = fs[:key]||Time.now.to_i
      file.write(Graphml::header(key))
    end

    #{:id => name, :for => ["node"||"edge"], :attr_name => name, :attr_type => type}
    def self.generate_attribute_declarations(fs, file)
      attribute_declarations = []
      classes_for_attributes = {:statuses_count => Fixnum, :followers_count => Fixnum, :friends_count => Fixnum, :style => String}
      fs[:node_attributes].each do |node_attribute|
        attribute_declarations << {:id => node_attribute, :for => :node, :attr_name => node_attribute.to_s.split("_").collect{|w| w.capitalize}.join(" "), :attr_type => classes_for_attributes[node_attribute]}
      end
      fs[:edge_attributes].each do |edge_attribute|
        attribute_declarations << {:id => edge_attribute, :for => :edge, :attr_name => edge_attribute.to_s.split("_").collect{|w| w.capitalize}.join(" "), :attr_type => classes_for_attributes[edge_attribute]}
      end
      file.write(Graphml::attribute_declarations(attribute_declarations))
    end

    def self.generate_nodes(fs, edges, file)
      node_names = edges.collect{|edge| [edge.start_node, edge.end_node]}.flatten.uniq
      node_names.each do |node_name|
        node = {:id => node_name, :label => node_name}.merge(self.generate_node_metadata(fs,node_name))
        file.write(Graphml::node(node))
      end
    end

    def self.generate_edges(fs, edges, file)
      edges.each do |edge|
        edge_data = {:id => edge.edge_id, :source => edge.start_node, :target => edge.end_node}.merge(self.generate_edge_metadata(fs, edge))
        file.write(Graphml::edge(edge_data))
      end
    end

    #SQL CALL GOTCHA: many attributes will need to make many calls to the database in the case for nodes (and to a lesser extent, edges)
    #This will make REALLY LONG generation times for large graphs, but may be unavoidable.
    def self.generate_node_metadata(fs, node_name)
      attributes = {:attributes => []}
      attributes
    end

    def self.generate_edge_metadata(fs, edge)
      attributes = {:attributes => []}
      fs[:edge_attributes].each do |edge_attribute|
        case edge_attribute
        when :style
          attributes[:attributes] << {:style => edge.style}
        end
      end
      attributes
    end
  end
end