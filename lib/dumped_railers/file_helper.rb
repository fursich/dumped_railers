# frozen_string_literal: true

require "yaml"

module DumpedRailers
  module FileHelper
    class << self
      def read_fixtures(*paths, yaml_column_permitted_classes: [])
        yaml_files = paths.flat_map { |path|
          if File.file?(path)
            path
          else
            [*Dir["#{path}/{**,*}/*.yml"], "#{path}.yml"].select { |f|
              ::File.file?(f)
            }
          end
        }.uniq.compact

        yaml_files.map { |file| 
          raw_data = ::File.read(file)
          YAML.safe_load(raw_data, permitted_classes: yaml_column_permitted_classes)
        }
      end

      def write(*fixtures, base_dir:)
        fixtures.each do |table_name, fixture|
          pathname = 
            if defined?(Rails)
              Rails.root.join("#{base_dir}/#{table_name}.yml")
            else
              Pathname.new("#{base_dir}/#{table_name}.yml")
            end

          pathname.open('w') do |f|
            f.write fixture.to_yaml
          end
        end
      end
    end
  end
end
