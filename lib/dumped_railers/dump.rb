# frozen_string_literal: true

require_relative 'fixture_builder/model'
require_relative 'preprocessor/strip_ignorables'

module DumpedRailers
  class Dump
    def initialize(*models)
      @fixture_tables = models.map { |model|
        FixtureBuilder::Model.new(model)
      }
    end

    def build_fixtures!
      @fixtures = @fixture_tables.map(&:build!).to_h
    end

    def persist_all!(base_dir)
      if base_dir
        FileUtils.mkdir_p(base_dir)
        FileHelper.write(*@fixtures, base_dir: base_dir)
      end
    end
  end
end
