# frozen_string_literal: true

require 'dumped_railers/version'
require 'dumped_railers/file_helper.rb'
require 'dumped_railers/dump'
require 'dumped_railers/import'
require 'dumped_railers/configuration'

module DumpedRailers
  extend Configuration

  class << self
    def dump!(*models, base_dir: nil, preprocessors: nil)
      config.preprocessors.unshift(Preprocessor::StripIgnorables.new)
      config.preprocessors += preprocessors if preprocessors.present?

      fixture_handler = Dump.new(*models)
      fixtures = fixture_handler.build_fixtures!
      fixture_handler.persist_all!(base_dir)

      fixtures
    end

    def import!(*paths, authorized_models: [])
      # make sure class-baseed caches starts with clean state
      DumpedRailers::RecordBuilder::FixtureRow::RecordStore.clear!
      DumpedRailers::RecordBuilder::DependencyTracker.clear!

      fixture_handler = Import.new(*paths, authorized_models: authorized_models)
      fixture_handler.import_all!
    end
  end

  configure_defaults!
end
