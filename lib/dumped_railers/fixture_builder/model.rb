# frozen_string_literal: true

require_relative 'record'

module DumpedRailers
  module FixtureBuilder
    class Model
      def initialize(model, preprocessors:)
        @model = model
        @fixture_records = model.order(:id).map { |record|
          Record.new(record, model, preprocessors: preprocessors)
        }
      end
  
      def build!
        fixture_body = @fixture_records.map(&:build!).to_h
        fixture = fixture_body.reverse_merge build_fixture_header_for(@model)
  
        [@model.table_name, fixture]
      end
  
      private

      def build_fixture_header_for(model)
        { '_fixture' =>
          {
            'model_class'          => model.name,
            'fixture_generated_by' => 'DumpedRailers',
          }
        }
      end
    end
  end
end
