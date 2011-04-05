module Gexf
  def self.header(attributes, mode="dynamic", default_edge_type="directed")
    attribute_class = attributes[:class]
    attribute_mode = attributes[:mode]
    attributes = attributes[:attributes]
    attributes_string = attributes.collect{|attribute| %{<attribute#{attribute.each_pair{|k,v| " #{k}=\"#{v}\""}}/>}}
    attribute_declarative_string = %{	<attributes class="#{attribute_class}" mode="#{attribute_mode}">
    #{attributes_string}
    </attributes>
    }
    %{<gexf xmlns="http://www.gexf.net/1.1draft"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.gexf.net/1.1draft
                             http://www.gexf.net/1.1draft/gexf.xsd"
      version="1.1">
  <graph mode="#{mode}" defaultedgetype="#{default_edge_type}">
  #{attribute_declarative_string}
  }
  end
  
  def self.footer
    "  </graph>\n</gexf>"
  end

  def self.nodes_header
    "  <nodes>\n"
  end

  def self.node_header(user)
    %{    <node id="#{user}" label="#{user}">}
  end
  
  def self.node_footer
    "    </node>\n"
  end
  
  def self.nodes_footer
    "  </nodes>\n"
  end
  
  def self.edges_header
    "  <edges>\n"
  end
  
  def self.edge_header(source, target, start_time="", end_time="", weight=1)
    %{    <edge source="#{source}" target="#{target}" start="#{start_time}" end="#{end_time}" weight="#{weight}">\n}
  end
  
  def self.edge_footer
    "    </edge>\n"
  end
  
  def self.edges_footer
    "  </edges>\n"
  end
  
  def self.attribute_header
    "      <attvalues>\n"
  end
  
  def self.attribute(attribute, value, start_time="", end_time="")
    %{        <attvalue for="#{attribute}" value="#{value}" start="#{start_time}" end="#{end_time}"/>\n}
  end
  
  def self.attribute_footer
    "      </attvalues>\n"
  end
  
  def self.slice_header
    "      <slices>\n"
  end
  
  def self.slice(start_time, end_time)
    %{        <slice start="#{start_time}" end="#{end_time}" />\n}
  end
  
  def self.slice_footer
    "      </slices>\n"
  end
end