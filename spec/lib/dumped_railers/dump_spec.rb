# frozen_string_literal: true

RSpec.describe DumpedRailers::Dump do
  describe '#build_fixtures!' do

    subject { fixture_generator.build_fixtures! }

    let!(:author1)  { Author.create!(name: 'William Shakespeare') }
    let!(:author2)  { Author.create!(name: 'Shikibu Murasaki') }
    let!(:article1) { Article.create!(title: 'Romeo and Juliet', writer: author1, published_date: '2020-10-10', published_time: '12:00:00', first_drafted_at: '2020-10-01 12:00:00') }
    let!(:article2) { Article.create!(title: 'King Lear',        writer: author1, published_date: '2021-10-10', published_time: '12:00:00', first_drafted_at: '2021-10-01 12:00:00') }
    let!(:article3) { Article.create!(title: 'Genji Monogatari', writer: author2, published_date: '2022-10-10', published_time: '12:00:00', first_drafted_at: '2022-10-01 12:00:00') }
    let(:models)    { [Author, Article] }

    context 'without any preprocessors' do
      let(:fixture_generator) { described_class.new(*models) }

      it {
        is_expected.to match(
          'authors' =>
           {
             '_fixture' =>
               {
                 'model_class' => 'Author',
                 'fixture_generated_by' => 'DumpedRailers',
               },
             "__author_#{author1.id}" => {
               'id' => author1.id,
               'name' => author1.name
             },
             "__author_#{author2.id}" => {
               'id' => author2.id,
               'name' => author2.name
             },
           },
          'articles' =>
          {
            '_fixture' =>
              {
                'model_class' => 'Article',
                'fixture_generated_by' => 'DumpedRailers',
              },
            "__article_#{article1.id}" => {
              'id' => article1.id,
              'title' => article1.title,
              'writer' => "__author_#{author1.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2020-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2020-10-01 12:00:00')
              ),
            },
            "__article_#{article2.id}" => {
              'id' => article2.id,
              'title' => article2.title,
              'writer' => "__author_#{author1.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2021-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2021-10-01 12:00:00')
              ),
            },
            "__article_#{article3.id}" => {
              'id' => article3.id,
              'title' => article3.title,
              'writer' => "__author_#{author2.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2022-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2022-10-01 12:00:00')
              ),
            },
          }
        )
      }
    end

    context 'with a preprocessor given' do
      let(:fixture_generator) { described_class.new(*models, preprocessors: preprocessors) }
      let(:preprocessors) { [strip_id, upcase_author_name] }

      let(:strip_id) {
        -> (_model, attrs) { attrs.except!('id') }
      }

      let(:upcase_author_name) {
        -> (_model, attrs) {
          attrs['name'].upcase! if attrs.has_key? 'name'
        }
      }

      it {
        is_expected.to match(
          'authors' =>
           {
             '_fixture' =>
               {
                 'model_class' => 'Author',
                 'fixture_generated_by' => 'DumpedRailers',
               },
             "__author_#{author1.id}" => {
               'name' => author1.name.upcase
             },
             "__author_#{author2.id}" => {
               'name' => author2.name.upcase
             },
           },
          'articles' =>
          {
            '_fixture' =>
            {
              'model_class' => 'Article',
              'fixture_generated_by' => 'DumpedRailers',
            },
            "__article_#{article1.id}" => {
              'title' => article1.title,
              'writer' => "__author_#{author1.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2020-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2020-10-01 12:00:00')
              ),
            },
            "__article_#{article2.id}" => {
              'title' => article2.title,
              'writer' => "__author_#{author1.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2021-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2021-10-01 12:00:00')
              ),
            },
            "__article_#{article3.id}" => {
              'title' => article3.title,
              'writer' => "__author_#{author2.id}",
              'published_date' => have_attributes(
                to_formatted_s: '2022-10-10'
              ),
              'published_time' => have_attributes(
                to_formatted_s: a_string_including('12:00:00')
              ),
              'first_drafted_at' => have_attributes(
                to_formatted_s: a_string_including('2022-10-01 12:00:00')
              ),
            },
          }
        )
      }
    end
  end

  describe '#persist_all!' do
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
