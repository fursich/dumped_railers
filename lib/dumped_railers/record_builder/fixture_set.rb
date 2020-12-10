# frozen_string_literal: true

require_relative 'fixture_table'
require 'tsort'

module DumpedRailers
  module RecordBuilder
    class FixtureSet
      include TSort
      attr_reader :fixture_tables, :record_sets
  
      def initialize(raw_fixtures)
        @fixture_tables = raw_fixtures.map { |raw_records| build_fixture_table(raw_records) }
      end
  
      def sort_by_table_dependencies!
        @fixture_tables.each(&:analyze_metadata_dependencies!)
        # dependency are sorted in topological order using Active Record reflection
        @fixture_tables = tsort
  
        self
      end
  
      def build_record_sets!
        @record_sets = @fixture_tables.map { |table|
          [table.model, table.build_records!]
        }.to_h
      end
  
      private
  
      def build_fixture_table(raw_records)
        FixtureTable.new(raw_records)
      end
  
      def tsort_each_node(&block)
        @fixture_tables.each { |table| block.call(table) }
      end
  
      def tsort_each_child(node, &block)
        dependent_nodes = @fixture_tables.select { |table| node.dependencies.include? table.model_name }
        dependent_nodes.each &block
      end
    end
  end
end
