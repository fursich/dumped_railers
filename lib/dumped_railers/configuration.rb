# frozen_string_literal: true

require 'forwardable'
require 'ostruct'
module DumpedRailers
  module Configuration
    extend Forwardable
    def_delegators :@_config, :preprocessors, :ignorable_columns, :authorized_models, :yaml_column_permitted_classes

    def configure
      yield config
    end

    def options
      config.to_h
    end

    IGNORABLE_COLUMNS = %w[id created_at updated_at]
    def configure_defaults!
      default_yaml_column_permitted_classes =
        # FIXME: this will be no longer needed when we drop support for older Rails versions
        # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
        if ActiveRecord.respond_to?(:yaml_column_permitted_classes)
          ActiveRecord.yaml_column_permitted_classes + [Date, Time, DateTime]
        else
          [Date, Time, DateTime]
        end

      clear_configuration!(
        ignorable_columns: IGNORABLE_COLUMNS,
        preprocessors: [],
        authorized_models: :any,
        yaml_column_permitted_classes: default_yaml_column_permitted_classes,
      )
    end

    def config
      @_config ||= OpenStruct.new
    end
    private :config

    def clear_configuration!(**attrs)
      @_config = OpenStruct.new(attrs)
    end
    private :clear_configuration!
  end
end
