require 'active_record'
require 'yaml'

File.delete('spec/support/dumped_railers.sqlite3') if File.exist? 'spec/support/dumped_railers.sqlite3'

dbconfig = YAML::load(File.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))

ActiveRecord::Base.belongs_to_required_by_default = true
ActiveRecord::Base.establish_connection(dbconfig[ENV['DB'] || 'sqlite'])

