# if Rails.env == "development"
#   path = File.dirname(__FILE__) + '/../../../code/analyzer/tools/'
#   file_set = `ls #{path}`.split("\n").collect{|f| path+f}
#   lib_reloader = ActiveSupport::FileUpdateChecker.new(file_set) do
#     Rails.application.reload_routes! # or do something better here
#   end
# 
#   ActionDispatch::Callbacks.to_prepare do
#     lib_reloader.execute_if_updated
#   end
# end

