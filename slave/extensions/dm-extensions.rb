require 'rubygems'
require 'dm-core'
require './extensions/array'

module DataMapperExtensions
  
  MAX_ROW_COUNT_PER_BATCH = 1000
  
  
  def save_all(objs, storage_prefix="insert ignore into ") # takes array of objs, hashes, or a mix of both
    hashes = objs.collect {|h| h.is_a?(Hash) ? h : h.attributes }
    hashes.chunk(((hashes.length-1)/MAX_ROW_COUNT_PER_BATCH)+1)
    keys = hashes.collect {|h| h.keys }.flatten.uniq
    qs = "("+[].fill("?", 0, keys.length).join(", ")+")"
    sql_vals = [].fill(qs, 0, hashes.length).join(", ")
    sql = "#{storage_prefix} #{self.storage_name} (#{keys.join(", ")}) values #{sql_vals}"
    vals = []
    hashes.each do |h|
      vals += keys.collect {|k| h[k] }
    end
    vals.flatten!
    DataMapper.repository(:default).adapter.execute(sql, *vals)
    return true
  end

  def update_all(objs, storage_prefix="replace into ") # takes array of objs, hashes, or a mix of both
    hashes = objs.collect {|h| h.is_a?(Hash) ? h : h.attributes }
    hashes.chunk(((hashes.length-1)/MAX_ROW_COUNT_PER_BATCH)+1)
    keys = hashes.collect {|h| h.keys }.flatten.uniq
    qs = "("+[].fill("?", 0, keys.length).join(", ")+")"
    sql_vals = [].fill(qs, 0, hashes.length).join(", ")
    sql = "#{storage_prefix} #{self.storage_name} (#{keys.join(", ")}) values #{sql_vals}"
    vals = []
    hashes.each do |h|
      vals += keys.collect {|k| h[k] }
    end
    vals.flatten!
    DataMapper.repository(:default).adapter.execute(sql, *vals)
    return true
  end
  
end

DataMapper::Model.append_extensions(DataMapperExtensions)