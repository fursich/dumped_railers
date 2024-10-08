# frozen_string_literal: true

RSpec.describe DumpedRailers::FixtureBuilder::Record do
  describe '#build!' do
    let(:fixture_builder) { described_class.new(record, model, preprocessors: preprocessors) }

    describe 'interface' do
      subject { fixture_builder.build! }

      let(:record) { Author.create!(name: 'Maurice Leblanc') }
      let(:model)  { Author }
      let(:preprocessors) { [] }

      it { is_expected.to be_an(Array) }
      it {
        is_expected.to match(
          a_collection_containing_exactly(
            a_string_starting_with('__'),
            a_hash_including('id' => record.id)
          )
        )
      }
    end

    describe 'attributes' do
      subject { fixture_builder.build!.last }
      let(:preprocessors) { [] }

      context 'when the record has no references' do
        let(:record) { Author.create!(name: 'Conan Doyle') }
        let(:model)  { Author }

        it {
          is_expected.to match(
            'id'   => record.id,
            'name' => 'Conan Doyle'
          )
        }
      end

      context 'when the record has a direct reference (using primary_key)' do
        let(:author) { Author.create!(name: 'Edgar Allan Poe') }
        let(:record) { Article.create!(title: 'The Murders in the Rue Morgue', writer: author, published_date: '2020-01-01', published_time: '12:00:00') }
        let(:model)  { Article }

        it {
          is_expected.to match(
            'id' => record.id,
            'title' => 'The Murders in the Rue Morgue',
            'writer' => "__author_#{author.id}",
            'published_date' => have_attributes(
              to_formatted_s: '2020-01-01'
            ),
            'published_time' => have_attributes(
              to_formatted_s: a_string_including('12:00:00')
            ),
            'first_drafted_at' => nil,
          )
        }
      end

      context 'when the record has a polymorpic reference' do
        let(:author)          { Author.create!(name: 'Edgar Allan Poe') }
        let(:article)         { Article.create!(title: 'The Murders in the Rue Morgue', writer: author) }
        let(:record)          { ContentHolder.create!(content: pixture_content, article: article) }
        let(:pixture_content) { PictureContent.create!(file: { path: 'foo/bar', filename: 'baz.jpg' }) }
        let(:model)           { ContentHolder }

        it {
          is_expected.to match(
            'id'      => record.id,
            'article' => "__article_#{article.id}",
            'content' => "__picture_content_#{pixture_content.id}(PictureContent)"
          )
        }
      end

      context 'for null association' do
        let(:record)          { ContentHolder.create!(content: pixture_content) }
        let(:pixture_content) { PictureContent.create!(file: { path: 'foo/bar', filename: 'baz.jpg' }) }
        let(:model)           { ContentHolder }

        it {
          is_expected.to match(
            'id'      => record.id,
            'article' => nil,
            'content' => "__picture_content_#{pixture_content.id}(PictureContent)"
          )
        }
      end
    end

    describe 'record_label' do
      subject { fixture_builder.build!.first }

      let(:record) { Author.create!(name: 'Conan Doyle') }
      let(:model)  { Author }
      let(:preprocessors) { [] }

      it { is_expected.to eq "__author_#{record.id}" }
    end

    describe 'preprocessors' do
      subject { fixture_builder.build! }

      let(:record) { Author.create!(name: 'Gosho Aoyama') }
      let(:model)  { Author }

      describe 'interface' do
        let(:preprocessor1) { double(:preprocessor).tap { |mock| allow(mock).to receive(:call) } }
        let(:preprocessor2) { double(:preprocessor).tap { |mock| allow(mock).to receive(:call) } }
        let(:preprocessors) { [preprocessor1, preprocessor2] }

        it 'receives :call method once' do
          result = subject

          expect(preprocessor1).to have_received(:call).with(Author, record.attributes).once
          expect(preprocessor2).to have_received(:call).with(Author, record.attributes).once
        end
      end

      describe 'order' do
        let(:preprocessor1) {
          -> (model, attrs) {
            attrs['name']  = 'Ranpo'
          }
        }
        let(:preprocessor2) {
          -> (model, attrs) {
            attrs['name']  += ' Edogawa'
          }
        }
        let(:preprocessors) { [preprocessor1, preprocessor2] }

        it 'is invoked from first elements to last elements' do
          expect(subject).to contain_exactly(
            "__author_#{record.id}",
            {
              'id'   => anything,
              'name' =>'Ranpo Edogawa',
            },
          )
        end
      end
    end
  end
end
