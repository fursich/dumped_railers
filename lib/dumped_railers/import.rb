# frozen_string_literal: true

require_relative 'record_builder/fixture_set'

module DumpedRailers
  class Import
    attr_reader :fixture_set

    def initialize(*paths, authorized_models: [])
      if (paths.first.is_a? Hash)
        @raw_fixtures = paths.first.values
      else
        @raw_fixtures = FileHelper.read_fixtures(*paths)
      end

      @fixture_set = RecordBuilder::FixtureSet.new(@raw_fixtures, authorized_models: authorized_models)
    end

    def import_all!
      fixture_set.authorize_models!
      fixture_set.sort_by_table_dependencies!
      @record_sets = fixture_set.build_record_sets!

      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        # models have to be persisted one-by-one so that dependent models are able to 
        # resolve "belongs_to" (parent) association
        @record_sets.each do |_model, records|
          # FIXME: faster implementation wanted, parhaps with activerocord-import
          # (objects needs to be reloaded somehow when using buik insert)
          records.each(&:save!)
        end
      end
    end
  end
end

