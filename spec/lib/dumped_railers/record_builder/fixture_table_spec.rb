# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::FixtureTable do

  describe '#initialize' do
    let(:fixture_table) { described_class.new(raw_records) }

    let(:raw_records) {
      {
        '_fixture' => fixture,
        '__record_a' => {
          'id' => 11,
          'name' => 'Du Fu',
        },
        '__record_b' => {
          'id' => 2,
          'name' => 'Sun Tsu',
        },
      }
    }

    describe 'fixture_table#.model' do
      subject { fixture_table.model }

      context 'with a model_name given' do
        let(:fixture)  {
          {
            'model_class' => model_name
          }
        }
  
        context 'with an existing model_name'do
          let(:model_name) { 'Author' }
  
          it  { is_expected.to eq Author }
        end
  
        context 'with an unexisting model_name'do
          let(:model_name) { 'People' }
  
          it 'raises RuntimeError' do
            expect { subject }.to raise_error RuntimeError
          end
        end
      end

      context 'without a model_name' do
        let(:fixture)  { {} }

        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end
      end
    end

    describe 'fixture_table#rows' do
      let(:fixture)  {
        {
          'model_class' => 'Author'
        }
      }

      before do
        allow(DumpedRailers::RecordBuilder::FixtureRow).to receive(:new).and_return(:a_record)
      end

      subject { fixture_table }

      it 'intializes FixtureRow twice in total' do
        subject

        expect(DumpedRailers::RecordBuilder::FixtureRow).to have_received(:new).twice
      end

      it 'intializes FixtureRow with given labels and attributes' do
        subject

        expect(DumpedRailers::RecordBuilder::FixtureRow).to have_received(:new).with(
          :__record_a,
          {
            id: 11,
            name: 'Du Fu',
          }
        ).ordered
        expect(DumpedRailers::RecordBuilder::FixtureRow).to have_received(:new).with(
          :__record_b,
          {
            id: 2,
            name: 'Sun Tsu',
          }
        ).ordered
      end

      it 'stores FixtureRow objects that are generated' do
        expect(fixture_table.rows).to contain_exactly(:a_record, :a_record)
      end
    end
  end

  describe '#analyze_metadata_dependencies!' do
    context 'with a model that have no dependencies' do
      let(:author_fixture) { described_class.new(author_records) }
      let(:author_records) {
        {
          '_fixture' => {
            'model_class'=> 'Author'
          },
          '__author_1' => {
            'name' => 'Du Fu',
          },
          '__author_2' => {
            'name' => 'Sun Tsu',
          },
        }
      }
  
      subject { author_fixture.dependencies }

      before do
        author_fixture.analyze_metadata_dependencies!
      end
  
      it 'detects no dependencies' do
        expect(subject).to be_empty
      end
    end

    context 'with a model that has (non-polymorphic) dependencies' do
      let(:article_fixture) { described_class.new(article_records) }
      let(:article_records) {
        {
          '_fixture' => {
            'model_class'=> 'Article'
          },
          '__article_1' => {
            'title' => 'A Spring View',
            'author' => '__author_1'
          },
          '__article_2' => {
            'title' => 'The Art of War',
            'author' => '__author_2'
          },
          '__article_3' => {
            'title' => 'To My Retired Friend Wei',
            'author' => '__author_1'
          },
        }
      }
  
      subject { article_fixture.dependencies }

      before do
        article_fixture.analyze_metadata_dependencies!
      end
    
      it 'detects dependency on Author' do
        expect(subject).to contain_exactly(:Author)
      end
    end

    context 'with a model that has polymorphic dependencies' do
      let(:content_holder_fixture) { described_class.new(content_holder_records) }
      let(:content_holder_records) {
        {
          '_fixture' => {
            'model_class'=> 'ContentHolder'
          },
          '__content_holder_1' => {
            'content' => '__content_8(TextContent)',
          },
          '__content_holder_2' => {
            'content' => '__content_3(VideoContent)',
          },
          '__content_holder_3' => {
            'content' => '__content_12(TextContent)',
          },
        }
      }
  
      subject { content_holder_fixture.dependencies }

      before do
        content_holder_fixture.analyze_metadata_dependencies!
      end
    
      it 'detects dependency on Article, TextContent and VideoContent' do
        expect(subject).to contain_exactly(:Article, :TextContent, :VideoContent)
      end
    end

    context 'when invoked twice' do
      let(:author_fixture) { described_class.new(author_records) }
      let(:author_records) {
        {
          '_fixture' => {
            'model_class'=> 'Author'
          },
          '__author_1' => {
            'name' => 'Du Fu',
          },
          '__author_2' => {
            'name' => 'Sun Tsu',
          },
        }
      }
  
      subject { author_fixture.analyze_metadata_dependencies! }

      before do
        author_fixture.analyze_metadata_dependencies!
      end
  
      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end

  describe '#build_records!' do
    context 'with a model that have no dependencies' do
      let(:author_fixture) { described_class.new(author_records).tap(&:analyze_metadata_dependencies!) }
      let(:author_records) {
        {
          '_fixture' => {
            'model_class'=> 'Author'
          },
          '__author_1' => {
            'name' => 'Du Fu',
          },
          '__author_2' => {
            'name' => 'Sun Tsu',
          },
        }
      }
  
      subject { author_fixture.build_records! }

      it 'builds two records' do
        expect(subject.size).to eq(2)
      end

      it 'consists of Author instances' do
        expect(subject.first).to be_an_instance_of Author
        expect(subject.second).to be_an_instance_of Author
      end

      it 'has attributes specified in the fixture' do
        expect(subject.first).to have_attributes(
          name: 'Du Fu'
        )

        expect(subject.second).to have_attributes(
          name: 'Sun Tsu'
        )
      end
    end

    context 'with a model that has (non-polymorphic) dependencies' do
      let(:article_fixture) { described_class.new(article_records).tap(&:analyze_metadata_dependencies!) }
      let(:article_records) {
        {
          '_fixture' => {
            'model_class'=> 'Article'
          },
          '__article_1' => {
            'title' => 'A Spring View',
            'author' => '__author_1'
          },
          '__article_2' => {
            'title' => 'The Art of War',
            'author' => '__author_2'
          },
          '__article_3' => {
            'title' => 'To My Retired Friend Wei',
            'author' => '__author_1'
          },
        }
      }
  
      subject { article_fixture.build_records! }

      context 'when no fixtures for dependent tables were given' do
        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end
      end

      context 'when the fixtures for dependent tables were given' do
        let(:author_fixture) { described_class.new(author_records).tap(&:analyze_metadata_dependencies!) }
        let(:author_records) {
          {
            '_fixture' => {
              'model_class'=> 'Author'
            },
            '__author_1' => {
              'name' => 'Du Fu',
            },
            '__author_2' => {
              'name' => 'Sun Tsu',
            },
          }
        }

        context 'when depender (Article) comes earlier than dependee (Author)' do
          subject {
            article_fixture.build_records!
            author_fixture.build_records!
          }

          it 'raises RuntimeError' do
            expect { subject }.to raise_error RuntimeError
          end
        end

        context 'when dependee (Author) comes earlier than depender (Article)' do
          before do
            author_fixture.build_records!
          end

          subject { article_fixture.build_records! }

          it 'builds three records' do
            expect(subject.size).to eq(3)
          end

          it 'consists of Article instances' do
            expect(subject.first).to be_an_instance_of Article
            expect(subject.second).to be_an_instance_of Article
            expect(subject.last).to be_an_instance_of Article
          end

          it 'has attributes specified in the fixture' do
            expect(subject.first).to have_attributes(
              title: 'A Spring View',
              author: have_attributes(
                name: 'Du Fu'
              ),
            )
            expect(subject.second).to have_attributes(
              title: 'The Art of War',
              author: have_attributes(
                name: 'Sun Tsu'
              ),
            )
            expect(subject.last).to have_attributes(
              title: 'To My Retired Friend Wei',
              author: have_attributes(
                name: 'Du Fu'
              ),
            )
          end
        end
      end
    end

    context 'with a model that has polymorphic dependencies' do
      let(:content_holder_fixture) { described_class.new(content_holder_records).tap(&:analyze_metadata_dependencies!) }
      let(:content_holder_records) {
        {
          '_fixture' => {
            'model_class'=> 'ContentHolder'
          },
          '__content_holder_1' => {
            'content' => '__text_content_8(TextContent)',
          },
          '__content_holder_2' => {
            'content' => '__video_content_3(VideoContent)',
          },
          '__content_holder_3' => {
            'content' => '__text_content_12(TextContent)',
          },
        }
      }
  
      subject { content_holder_fixture.build_records! }

      context 'when no fixtures for dependent tables were given' do
        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end
      end

      context 'when the fixtures for dependent tables were given' do
        let(:text_content_fixture) { described_class.new(text_content_records).tap(&:analyze_metadata_dependencies!) }
        let(:text_content_records) {
          {
            '_fixture' => {
              'model_class'=> 'TextContent'
            },
            '__text_content_8' => {
              'body' => 'Michelle, ma belle',
            },
            '__text_content_12' => {
              'body' => 'Picture yourself in a boat on a river',
            },
          }
        }

        let(:video_content_fixture) { described_class.new(video_content_records).tap(&:analyze_metadata_dependencies!) }
        let(:video_content_records) {
          {
            '_fixture' => {
              'model_class'=> 'VideoContent'
            },
            '__video_content_3' => {
              'file' => { name: 'paperback_writer.mp4', path: 'past_masters/vol_two' }
            },
          }
        }

        context 'when depender (ContentHolder) comes earlier than dependee (VideoContent, TextContent)' do
          subject {
            content_holder_fixture.build_records!
            text_content_fixture.build_records!
            video_content_fixture.build_records!
          }

          it 'raises RuntimeError' do
            expect { subject }.to raise_error RuntimeError
          end
        end

        context 'when dependee (Author) comes earlier than depender (Article)' do
          before do
            text_content_fixture.build_records!
            video_content_fixture.build_records!
          end

          subject { content_holder_fixture.build_records! }

          it 'builds three records' do
            expect(subject.size).to eq(3)
          end

          it 'consists of Article instances' do
            expect(subject.first).to be_an_instance_of ContentHolder
            expect(subject.second).to be_an_instance_of ContentHolder
            expect(subject.last).to be_an_instance_of ContentHolder
          end

          it 'has attributes specified in the fixture' do
            expect(subject.first).to have_attributes(
              content: have_attributes(
                body: 'Michelle, ma belle'
              ),
            )
            expect(subject.second).to have_attributes(
              content: have_attributes(
                file: { 'name' => 'paperback_writer.mp4', 'path' =>'past_masters/vol_two' }
              ),
            )
            expect(subject.last).to have_attributes(
              content: have_attributes(
                body: 'Picture yourself in a boat on a river'
              ),
            )
          end
        end
      end
    end

    context 'when a part of the dependee records are missing' do
      let(:article_fixture) { described_class.new(article_records).tap(&:analyze_metadata_dependencies!) }
      let(:article_records) {
        {
          '_fixture' => {
            'model_class'=> 'Article'
          },
          '__article_1' => {
            'title' => 'A Spring View',
            'author' => '__author_1'
          },
          '__article_2' => {
            'title' => 'The Art of War',
            'author' => '__author_2'
          },
        }
      }
      let(:author_fixture) { described_class.new(author_records).tap(&:analyze_metadata_dependencies!) }
      let(:author_records) {
        {
          '_fixture' => {
            'model_class'=> 'Author'
          },
          '__author_1' => {
            'name' => 'Du Fu',
          },
        }
      }
  
      subject { article_fixture.build_records! }

      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end

    context 'when invoked twice' do
      let(:author_fixture) { described_class.new(author_records).tap(&:analyze_metadata_dependencies!) }
      let(:author_records) {
        {
          '_fixture' => {
            'model_class'=> 'Author'
          },
          '__author_1' => {
            'name' => 'Du Fu',
          },
          '__author_2' => {
            'name' => 'Sun Tsu',
          },
        }
      }
  
      subject { author_fixture.build_records! }

      before do
        author_fixture.build_records!
      end
  
      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end
end
