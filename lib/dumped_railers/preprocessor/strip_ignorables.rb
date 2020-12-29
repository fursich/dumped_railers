# frozen_string_literal: true

module DumpedRailers
  module Preprocessor
    class StripIgnorables
      def initialize(*ignorable_columns)
        @ignorable_columns = ignorable_columns.compact.map(&:to_s)
      end

      def call(attributes, _model)
        attributes.reject { |column_name, _v|
          @ignorable_columns.include?(column_name)
        }
      end
    end
  end
end
