# frozen_string_literal: true

module DumpedRailers
  module RecordBuilder
    class FixtureRow
      attr_reader :label, :attrs
  
      def initialize(label, attrs)
        @label = label
        @attrs = attrs
      end

      def analyze_dependencies!(dependency_tracker)
        raise RuntimeError, 'Can\'t execute the dependency analysis twice. This has been done already' if @dependency

        @dependency =  dependency_tracker

        attrs.each do |attr, value|
          ref, model_name = parse_reference_from(value)
          next unless ref
  
          attrs[attr] = ref.to_sym
          @dependency.with(attr).record_label = ref.to_sym
          @dependency.with(attr).model_name   = model_name&.to_sym
        end
      end

      def instantiate_as!(model)
        raise RuntimeError, 'Could not find the dependency tracker. Run #analyze_dependencies to instaitiate the records' unless @dependency

        @model = model
        resolve_reference!
        object = model.new(attrs)
        RecordStore.register(label, object: object)
  
        object
      end
  
      private
  
      def parse_reference_from(val)
        # NOTE: make sure its object is a string (can be a json object)
        return unless val.is_a? String
        return unless val.start_with? '__'
  
        # format convention
        # for non-polymorphic association: __[identifier]
        # for polymorphic association:     __[identifier]([model_name])
        ref, _, model_name = val.scan(/\A(__[^(\s]+)(\(([^)]+)\))?\z/).first
  
        [ref, model_name]
      end
  
      def resolve_reference!
        raise RuntimeError, <<~"ERROR_MESSAGE" unless resolvable?
          cannot resolve dependencies. (some fixtures might be missing)
            model:  #{@model}
            record: #{label}
          ERROR_MESSAGE
  
        @dependency.each_dependent_record_label { |attr, record_label|
          attrs[attr] = RecordStore.retrieve!(record_label)
        }
      end
  
      def resolvable?
        @dependency.dependent_record_labels.all? { |label|
          RecordStore.registered?(label)
        }
      end

      class RecordStore
        class << self
          def register(label, object:)
            set_object(label, object)
          end
  
          def registered?(label)
            !object_for(label).nil?
          end
  
          def retrieve!(label)
            raise RuntimeError, "couldn't resolve dependent record: #{label}" unless registered?(label)
  
            object_for(label)
          end

          def clear!
            @repository = {}
          end
  
          private
  
          def repository
            @repository ||= {}
          end
  
          def object_for(label)
            repository[label.to_sym]
          end

          def set_object(label, object)
            repository[label.to_sym] = object
          end
        end

        def initialize
          # use this class as (some sort of) Singleton
          raise NotImplementedError
        end
      end
    end
  end
end
