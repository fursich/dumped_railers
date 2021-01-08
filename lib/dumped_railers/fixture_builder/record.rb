# frozen_string_literal: true

module DumpedRailers
  module FixtureBuilder
    class Record
      def initialize(record, model, preprocessors:)
        @record = record
        @model = model
        @preprocessors = preprocessors
      end

      def build!
        id = @record.id
        attributes = @record.attributes.deep_dup
        @preprocessors.each do |preprocessor|
          preprocessor.call(attributes, @model)
        end

        # convert "belong_to association" foreign keys into record-unique labels
        @model.reflect_on_all_associations.select(&:belongs_to?).each do |rel|
          # skip ignorables
          next unless attributes.has_key? rel.foreign_key.to_s

          if rel.polymorphic?
            class_name = attributes[rel.foreign_type.to_s]

            attributes[rel.name.to_s] = record_label_for(
              class_name,
              attributes.delete(rel.foreign_key.to_s),
              attributes.delete(rel.foreign_type.to_s)
            )
          else
            attributes[rel.name.to_s] = record_label_for(
              rel.class_name,
              attributes.delete(rel.foreign_key.to_s)
            )
          end
        end

        [record_label_for(@model.name, id), attributes]
      end

      private

      def record_label_for(class_name, id, type=nil)
        return nil unless id

        identifier = "#{class_name.to_s.underscore}_#{id}"
        type_specifier = "(#{type})" if type

        "__#{identifier}#{type_specifier}"
      end
    end
  end
end
