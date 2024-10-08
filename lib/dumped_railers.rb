# frozen_string_literal: true

require 'dumped_railers/version'
require 'dumped_railers/file_helper.rb'
require 'dumped_railers/dump'
require 'dumped_railers/import'
require 'dumped_railers/configuration'

module DumpedRailers
  extend Configuration

  class << self
    def dump!(*models, base_dir: nil, preprocessors: nil, ignorable_columns: nil)
      # override global config settings when options are specified
      runtime_options = { preprocessors: preprocessors.presence, ignorable_columns: ignorable_columns.presence }.compact.reverse_merge(dump_options.deep_dup)
      runtime_options[:preprocessors].unshift(
        default_preprocessor(runtime_options[:ignorable_columns])
      )

      fixture_handler = Dump.new(*models, preprocessors: runtime_options[:preprocessors])
      fixtures = fixture_handler.build_fixtures!
      fixture_handler.persist_all!(base_dir)

      fixtures
    end

    def import!(*paths, authorized_models: nil, before_save: nil, after_save: nil, yaml_column_permitted_classes: [])
      # make sure class-baseed caches starts with clean state
      DumpedRailers::RecordBuilder::FixtureRow::RecordStore.clear!
      DumpedRailers::RecordBuilder::DependencyTracker.clear!

      # override global config settings when options are specified
      runtime_options = 
        {
          authorized_models: authorized_models.presence,
          yaml_column_permitted_classes: yaml_column_permitted_classes.presence,
        }
        .compact
        .reverse_merge(import_options)

      before_save = Array(before_save).compact
      after_save  = Array(after_save).compact

      fixture_handler = Import.new(
        *paths,
        authorized_models: runtime_options[:authorized_models],
        before_save: before_save,
        after_save:  after_save,
        yaml_column_permitted_classes: runtime_options[:yaml_column_permitted_classes]
      )
      fixture_handler.import_all!
    end

    private

    def default_preprocessor(ignorable_columns)
      Preprocessor::StripIgnorables.new(*ignorable_columns)
    end

    def dump_options
      options.slice(:ignorable_columns, :preprocessors)
    end

    def import_options
      options.slice(:authorized_models, :yaml_column_permitted_classes)
    end
  end

  configure_defaults!
end
