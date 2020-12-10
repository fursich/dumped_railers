require 'bundler/setup'
require 'pry'
require 'database_cleaner/active_record'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'support'))
require 'active_record_helper'
require 'active_record_models'

require 'dumped_railers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # need to maintain class-baseed caches in clean state
  config.around(:each) do  |example|
    example.run
    DumpedRailers::RecordBuilder::FixtureRow::RecordStore.clear!
    DumpedRailers::RecordBuilder::DependencyTracker.clear!
  end
end
