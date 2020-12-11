# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::FixtureSet do

  let(:author_records) {
    {
      '_fixture' => {
        'model_class'=> 'Author'
      },
      '__author_1' => {
        'name' => 'J. J. Sakurai',
      },
      '__author_2' => {
        'name' => 'Lev Landau',
      },
      '__author_3' => {
        'name' => 'John von Neumann',
      },
    }
  }

  let(:article_records) {
    {
      '_fixture' => {
        'model_class'=> 'Article'
      },
      '__article_1' => {
        'title' => 'The Classical Theory of Fields',
        'writer' => '__author_2'
      },
      '__article_2' => {
        'title' => 'The Computer and the Brain',
        'writer' => '__author_3'
      },
      '__article_3' => {
        'title' => 'Modern Quantum Mechanics',
        'writer' => '__author_1'
      },
      '__article_4' => {
        'title' => 'Theory of Games and Economic Behavior',
        'writer' => '__author_3'
      },
    }
  }

  let(:content_holder_records) {
    {
      '_fixture' => {
        'model_class'=> 'ContentHolder'
      },
      '__content_holder_1' => {
        'article' => '__article_3',
        'content' => '__text_content_8(TextContent)',
      },
      '__content_holder_2' => {
        'article' => '__article_1',
        'content' => '__picture_content_3(PictureContent)',
      },
      '__content_holder_3' => {
        'content' => '__text_content_12(TextContent)',
      },
    }
  }

  let(:text_content_records) {
    {
      '_fixture' => {
        'model_class'=> 'TextContent'
      },
      '__text_content_8' => {
        'body' => 'The revolutionary change in our understanding of microscopic phenomena that took place during the first 27 years of the twentieth century is unprecedented in the histroy of classical physics'
      },
      '__text_content_12' => {
        'body' => 'If people do not believe that mathematics is simple, it is only because they do not realize how complicated life is.'
      },
    }
  }

  let(:picture_content_records) {
    {
      '_fixture' => {
        'model_class'=> 'PictureContent'
      },
      '__picture_content_3' => {
        'file' => { name: 'landau_and_lifshitz.jpg' }
      },
    }
  }

  describe '#sort_by_table_dependencies!' do
    let(:raw_fixtures) {
      [article_records, picture_content_records, author_records, content_holder_records, text_content_records]
    }

    let(:fixture_set) { described_class.new(raw_fixtures) }

    describe 'models sorted in dependency order' do
      before do
        fixture_set.sort_by_table_dependencies!
      end

      subject { fixture_set.fixture_tables.map(&:model_name) }
  
      it 'places Author records prior to Article records' do
        expect(subject.index(:Author)).to be < subject.index(:Article)
      end
  
      it 'places Article records prior to ContentHolder records' do
        expect(subject.index(:Article)).to be < subject.index(:ContentHolder)
      end
  
      it 'places TextContent records prior to ContentHolder records' do
        expect(subject.index(:TextContent)).to be < subject.index(:ContentHolder)
      end
  
      it 'places PictureContent records prior to ContentHolder records' do
        expect(subject.index(:PictureContent)).to be < subject.index(:ContentHolder)
      end
    end

    context 'when invoked twice' do
      before do
        fixture_set.sort_by_table_dependencies!
      end

      subject { fixture_set.sort_by_table_dependencies! }

      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end

  describe '#build_record_sets!' do
    let(:raw_fixtures) {
      [article_records, picture_content_records, author_records, content_holder_records, text_content_records]
    }

    let(:fixture_set) { described_class.new(raw_fixtures).tap(&:sort_by_table_dependencies!) }

    subject { fixture_set.build_record_sets! }

    it 'builds records that have associations specified in the fixtures' do
      expect(subject).to match(
        Author => a_collection_containing_exactly(
          have_attributes(
            name: 'J. J. Sakurai'
          ),
          have_attributes(
            name: 'Lev Landau'
          ),
          have_attributes(
            name: 'John von Neumann'
          ),
        ),

        Article => a_collection_containing_exactly(
          have_attributes(
            title: 'The Classical Theory of Fields',
            writer: have_attributes(
              name: 'Lev Landau'
            )
          ),
          have_attributes(
            title: 'The Computer and the Brain',
            writer: have_attributes(
              name: 'John von Neumann'
            )
          ),
          have_attributes(
            title: 'Modern Quantum Mechanics',
            writer: have_attributes(
              name: 'J. J. Sakurai'
            )
          ),
          have_attributes(
            title: 'Theory of Games and Economic Behavior',
            writer: have_attributes(
              name: 'John von Neumann'
            )
          ),
        ),

        ContentHolder => a_collection_containing_exactly(
          have_attributes(
            article: have_attributes(
              title: 'Modern Quantum Mechanics',
            ),
            content: have_attributes(
              body: 'The revolutionary change in our understanding of microscopic phenomena that took place during the first 27 years of the twentieth century is unprecedented in the histroy of classical physics'
            ),
          ),
          have_attributes(
            article: have_attributes(
              title: 'The Classical Theory of Fields',
            ),
            content: have_attributes(
              file: { 'name' => 'landau_and_lifshitz.jpg' }
            ),
          ),
          have_attributes(
            content: have_attributes(
              body: 'If people do not believe that mathematics is simple, it is only because they do not realize how complicated life is.'
            ),
          ),
        ),

        TextContent => a_collection_containing_exactly(
          have_attributes(
            body: 'The revolutionary change in our understanding of microscopic phenomena that took place during the first 27 years of the twentieth century is unprecedented in the histroy of classical physics'
          ),
          have_attributes(
            body: 'If people do not believe that mathematics is simple, it is only because they do not realize how complicated life is.'
          ),
        ),

        PictureContent => a_collection_containing_exactly(
          have_attributes(
            file: { 'name' => 'landau_and_lifshitz.jpg' }
          ),
        ),
      )
    end

    context 'when part of the dependent records are missing'do
      let(:raw_fixtures) {
        [article_records, picture_content_records, content_holder_records, text_content_records]
      }

      subject { fixture_set.build_record_sets! }

      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end

    context 'when invoked twice' do
      before do
        fixture_set.build_record_sets!
      end

      subject { fixture_set.build_record_sets! }

      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end
end
