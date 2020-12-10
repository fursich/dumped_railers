# frozen_string_literal: true

module DumpedRailers
  module Preprocessor
    class StripIgnorables
      def call(attributes, _model)
        attributes.reject { |column_name, _v|
          DumpedRailers.config.ignorable_columns.map(&:to_s).include?(column_name)
        }
      end
    end
  end
end
