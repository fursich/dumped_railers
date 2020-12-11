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
        let(:record) { Article.create!(title: 'The Murders in the Rue Morgue', writer: author) }
        let(:model)  { Article }
  
        it {
          is_expected.to match(
            'id'     => record.id,
            'title'  => 'The Murders in the Rue Morgue',
            'writer' => "__author_#{author.id}"
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
        let(:preprocessor1) { double(:preprocessor).tap { |mock| allow(mock).to receive(:call).and_return({processed_by: :preprocessor1}) } }
        let(:preprocessor2) { double(:preprocessor).tap { |mock| allow(mock).to receive(:call).and_return({processed_by: :preprocessor2}) } }
        let(:preprocessor3) { double(:preprocessor).tap { |mock| allow(mock).to receive(:call).and_return({processed_by: :preprocessor3}) } }
        let(:preprocessors) { [preprocessor1, preprocessor2, preprocessor3] }

        it 'receives :call method once' do
          result = subject

          expect(preprocessor1).to have_received(:call).with(record.attributes, Author).once
          expect(preprocessor2).to have_received(:call).with({ processed_by: :preprocessor1 }, Author).once
          expect(preprocessor3).to have_received(:call).with({ processed_by: :preprocessor2 }, Author).once
          expect(result).to contain_exactly("__author_#{record.id}", { processed_by: :preprocessor3 })
        end
      end

      describe 'ignore certain columns' do
      end
    end
  end
end
