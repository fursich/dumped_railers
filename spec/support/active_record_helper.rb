require 'active_record'
require 'yaml'

dbconfig = YAML::load(File.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
ActiveRecord::Base.establish_connection(dbconfig[ENV['DB'] || 'sqlite'])

