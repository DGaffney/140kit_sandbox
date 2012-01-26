require 'rubygems'
require 'dm-core'
require File.dirname(__FILE__)+'/array'

module DataMapperExtensions
  require 'faster_csv'
  MAX_ROW_COUNT_PER_BATCH = 1000
  include DataObjects::Quoting
  
  def save_all(objs, storage_prefix="insert ignore into ") # takes array of objs, hashes, or a mix of both
    return false if objs.empty?
    hashes = objs.collect {|h| h.is_a?(Hash) ? h : h.attributes }
    hashes.chunk(((hashes.length-1)/MAX_ROW_COUNT_PER_BATCH)+1)
    keys = hashes.collect {|h| h.keys }.flatten.uniq
    qs = "("+[].fill("?", 0, keys.length).join(", ")+")"
    sql_vals = [].fill(qs, 0, hashes.length).join(", ")
    sql = "#{storage_prefix} #{self.storage_name} (#{keys.uniq.join(", ")}) values #{sql_vals}"
    vals = []
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    hashes.each do |h|
      vals += keys.collect {|k| h[k].class == String ? ic.iconv(h[k]) : h[k] }
    end
    vals.flatten!
    case DataMapper.repository.adapter.options["adapter"]
    when "mysql"
      DataMapper.repository(:default).adapter.execute(sql, *vals)
      return true
    when "sqlite3"
      objs.each do |obj|
        inst_obj = self.new(obj)
        inst_obj.save
      end
    end
  end

  def update_all(objs, storage_prefix="replace into ") # takes array of objs, hashes, or a mix of both
    return false if objs.empty?
    hashes = objs.collect {|h| h.is_a?(Hash) ? h : h.attributes }
    hashes.chunk(((hashes.length-1)/MAX_ROW_COUNT_PER_BATCH)+1)
    keys = hashes.collect {|h| h.keys }.flatten.uniq
    qs = "("+[].fill("?", 0, keys.length).join(", ")+")"
    sql_vals = [].fill(qs, 0, hashes.length).join(", ")
    sql = "#{storage_prefix} #{self.storage_name} (#{keys.uniq.join(", ")}) values #{sql_vals}"
    vals = []
    hashes.each do |h|
      vals += keys.collect {|k| h[k] }
    end
    vals.flatten!
    case DataMapper.repository.adapter.options["adapter"]
    when "mysql"
      DataMapper.repository(:default).adapter.execute(sql, *vals)
      return true
    when "sqlite3"
      objs.each do |obj|
        inst_obj = self.first(:id => obj[:id])
        inst_obj.update(obj)
      end
    end
  end

  def store_to_flat_file(objs, file=File.dirname(__FILE__)+"/../../data/raw/file")
    Sh::mkdir(file.split("/")[0..file.split("/").length-2].join("/"), "local")
    return false if objs.empty?
    objs = objs.sth if objs.first.class != self && objs.first.class != Hash
    keys = objs.first.class == Hash ? objs.first.keys.collect(&:to_s).sort : objs.first.attributes.keys.collect(&:to_s).sort
    f = File.open(file+".tsv", "a+") 
    csv_header = CSV.generate_line(keys, :col_sep => "\t", :row_sep => "\0", :quote_char => '"')
    f.write(csv_header) #if Sh::sh("ls #{file.split("/")[0..file.split("/").length-2].join("/")}").include?(file.split("/").last+".csv")
    objs.each do |elem|
      begin
      row = CSV.generate_line(keys.collect{|k| elem[k.to_sym]}, :col_sep => "\t", :row_sep => "\0", :quote_char => '"')
      rescue
        debugger
        ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
        row = CSV.generate_line(keys.collect{|k| elem[k.to_sym].class == String ? elem[k.to_sym].encode("ISO-8859-1") : elem[k.to_sym]}, :col_sep => "\t", :row_sep => "\0", :quote_char => '"')
      end
      f.write(row)
    end
    f.close
  end
end

DataMapper::Model.append_extensions(DataMapperExtensions)

