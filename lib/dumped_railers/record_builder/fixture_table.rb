# frozen_string_literal: true

require_relative 'fixture_row'
require_relative 'dependency_tracker'

module DumpedRailers
  module RecordBuilder
    class FixtureTable
      attr_reader  :model, :model_name, :rows, :objects, :dependencies
  
      def initialize(raw_records)
        config = raw_records.delete('_fixture')
  
        @model = identify_model!(config)
        @model_name = model.name.to_sym
        @dependency_tracker = DependencyTracker.for(model)
  
        @rows = raw_records.map { |label, attrs|
          build_fixture_row(label, attrs)
        }
      end

      def analyze_metadata_dependencies!
        raise RuntimeError, "Dependency Analysis has already been done with the fixture for #{model_name}" if @dependencies

        rows.map { |row| row.analyze_dependencies!(@dependency_tracker.on(row)) }

        @dependencies = model.reflect_on_all_associations.select(&:belongs_to?).flat_map { |rel|
          if rel.polymorphic?
            @dependency_tracker.list_all_model_names_with(rel.name)
          else
            rel.class_name.to_sym
          end
        }.uniq
      end
  
      def build_records!
        raise RuntimeError, "The records in this fixture for #{model_name} have been built already" if @instantiated
  
        @objects = rows.map { |row| row.instantiate_as!(model) }
        @instantiated = true
  
        objects
      end
  
      private

      def build_fixture_row(label, attrs)
        FixtureRow.new(
          label.to_sym,
          attrs.symbolize_keys,
        )
      end

      def identify_model!(config)
        model_name = config&.dig('model_class')
        raise RuntimeError, <<~"ERROR_MESSAGE" unless model_name
          couldn't find `_fixture: model_class` label in the fixture.
          (possibly not an auto-generated one?)
        ERROR_MESSAGE
  
        model = model_name.safe_constantize
        return model if model && model < ActiveRecord::Base

        raise RuntimeError, <<~"ERROR_MESSAGE"
          couldn't find a model named #{model_name} specified with `_fixture: model_class` label in the fixture.
          you might want to check whether:
            - this task runs in the same application that the fixtures were generated in
            - relevant tables have not been altered or dropped since the fixtures were generated
        ERROR_MESSAGE
      end
    end
  end
end
