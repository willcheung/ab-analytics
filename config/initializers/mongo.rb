# MongoMapper.connection = Mongo::Connection.new('abanalytics100.domain.com', 27017)
# MongoMapper.database = "#exp_app-#{Rails.env}"
# 
# if defined?(PhusionPassenger)
#    PhusionPassenger.on_event(:starting_worker_process) do |forked|
#      MongoMapper.connection.connect if forked
#    end
# end