# frozen_string_literal: true

RSpec.describe DumpedRailers::FixtureBuilder::Model do
  describe '#build!' do
    before do
      DumpedRailers.configure do |config|
        config.preprocessors = preprocessors
      end
    end

    let(:fixture_builder) { described_class.new(model) }
    let(:preprocessors) { [] }

    subject { fixture_builder.build! }

    let!(:author1) { Author.create!(name: 'Agatha Christie') }
    let!(:author2) { Author.create!(name: 'Jiro Akagawa') }
    let(:model)  { Author }
    let(:preprocessors) { [] }

    it {
      is_expected.to contain_exactly(
        'authors',
         {
          '_fixture' =>
            {
              'model_class'          => model.name,
              'fixture_generated_by' => 'DumpedRailers',
            },
          "__author_#{author1.id}" => {
             'id'   => author1.id,
             'name' => author1.name
            },
          "__author_#{author2.id}" => {
             'id'   => author2.id,
             'name' => author2.name
            },
        }
      )
    }
  end
end
