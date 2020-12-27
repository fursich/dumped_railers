# frozen_string_literal: true

RSpec.describe DumpedRailers::Dump do
  describe '#build_fixtures!' do
    before do
      DumpedRailers.configure do |config|
        config.preprocessors = []
      end
    end

    let(:fixture_generator) { described_class.new(*models) }

    subject { fixture_generator.build_fixtures! }

    let!(:author1)  { Author.create!(name: 'William Shakespeare') }
    let!(:author2)  { Author.create!(name: 'Shikibu Murasaki') }
    let!(:article1) { Article.create!(title: 'Romeo and Juliet', writer: author1) }
    let!(:article2) { Article.create!(title: 'King Lear',        writer: author1) }
    let!(:article3) { Article.create!(title: 'Genji Monogatari', writer: author2) }
    let(:models)    { [Author, Article] }

    it {
      is_expected.to match(
        'authors' =>
         {
          '_fixture' =>
            {
              'model_class'          => 'Author',
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
        },
        'articles' =>
        {
         '_fixture' =>
           {
             'model_class'          => 'Article',
             'fixture_generated_by' => 'DumpedRailers',
           },
         "__article_#{article1.id}" => {
            'id'     => article1.id,
            'title'  => article1.title,
            'writer' => "__author_#{author1.id}",
           },
         "__article_#{article2.id}" => {
            'id'     => article2.id,
            'title'  => article2.title,
            'writer' => "__author_#{author1.id}",
           },
         "__article_#{article3.id}" => {
            'id'     => article3.id,
            'title'  => article3.title,
            'writer' => "__author_#{author2.id}",
           },
        }
      )
    }
  end

  describe '#persist_all!' do
    before do
      DumpedRailers.configure do |config|
        config.preprocessors = []
      end
    end

    let(:fixture_generator) { described_class.new(*models) }
    let!(:fixtures) { fixture_generator.build_fixtures! }

    let!(:author1)  { Author.create!(name: 'William Shakespeare') }
    let!(:author2)  { Author.create!(name: 'Shikibu Murasaki') }
    let!(:article1) { Article.create!(title: 'Romeo and Juliet', writer: author1) }
    let!(:article2) { Article.create!(title: 'King Lear',        writer: author1) }
    let!(:article3) { Article.create!(title: 'Genji Monogatari', writer: author2) }
    let(:models)    { [Author, Article] }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(DumpedRailers::FileHelper).to receive(:write)
    end

    subject { fixture_generator.persist_all!(base_dir) }

    context 'when base_dir is set' do
      let(:base_dir) { '/foo/bar/baz' }

      it 'creates the directory' do
        subject

        expect(FileUtils).to have_received(:mkdir_p).with(base_dir).once
      end

      it 'writes out fixtures into files' do
        subject

        expect(DumpedRailers::FileHelper).to have_received(:write).with(*fixtures, base_dir: base_dir).once
      end
    end

    context 'when base_dir is nil' do
      let(:base_dir) { nil }

      it 'does not create the directory' do
        subject

        expect(FileUtils).not_to have_received(:mkdir_p)
      end

      it 'writes out fixtures into files' do
        subject

        expect(DumpedRailers::FileHelper).not_to have_received(:write)
      end
    end
  end
end
