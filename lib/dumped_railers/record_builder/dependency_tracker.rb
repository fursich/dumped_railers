# frozen_string_literal: true

module DumpedRailers
  module RecordBuilder
    class DependencyTracker
      class <<  self
        def for(model)
          trackers[model] ||= new
        end

        def clear!
          @trackers = {}
        end

        private

        def trackers
          @trackers ||= {}
        end
      end

      def on(record)
        dependencies[record] ||= RecordDependency.new
      end

      def list_all_record_labels_with(attr)
        list_all_dependencies_with(attr)
          .map { |dependent| dependent.record_label }
          .compact
      end

      def list_all_model_names_with(attr)
        list_all_dependencies_with(attr)
          .map { |dependent| dependent.model_name }
          .compact
      end

      private

      def dependencies
        @dependencies ||= {}
      end

      def list_all_dependencies_with(attr)
        dependencies
          .values
          .map { |record_dependency|
            record_dependency.with(attr)
          }
      end

      class RecordDependency
        def with(attr)
          record_dependency[attr.to_sym] ||= DependentObject.new
        end

        def each_dependent_record_label(&block)
          return enum_for(:each_dependent_record_label) unless block_given?

          record_dependency.each { |attr, dependent_object|
            block.call(attr, dependent_object.record_label)
          }
        end

        def dependent_record_labels
          record_dependency.values.map(&:record_label).compact
        end

        private

        def record_dependency
          @record_dependency ||= {}
        end

        class DependentObject
          attr_accessor :record_label, :model_name
        end
      end

    end
  end
end
