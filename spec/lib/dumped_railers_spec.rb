# frozen_string_literal: true

RSpec.describe DumpedRailers do
  around do |example|
    DumpedRailers.instance_variable_set(:@_config, nil)
    DumpedRailers.configure_defaults!

    example.run
  end

  describe '.dump!' do

    let!(:author1)  { Author.create!(name: 'William Shakespeare') }
    let!(:author2)  { Author.create!(name: 'Shikibu Murasaki') }
    let!(:article1) { Article.create!(title: 'Romeo and Juliet', writer: author1) }
    let!(:article2) { Article.create!(title: 'King Lear',        writer: author1) }
    let!(:article3) { Article.create!(title: 'Genji Monogatari', writer: author2) }
    let(:models)    { [Author, Article] }

    describe 'returned values' do
      subject { DumpedRailers.dump!(*models) }

      it 'returns fixture data composed of record attributes by its model' do
        expect(subject).to match(
          'authors' => {
            '_fixture' =>
              {
                'model_class'          => 'Author',
                'fixture_generated_by' => 'DumpedRailers',
              },
            "__author_#{author1.id}" => {
              'name' => author1.name
            },
            "__author_#{author2.id}" => {
              'name' => author2.name
            },
          },
          'articles'  =>  {
            '_fixture' =>
              {
                'model_class'          => 'Article',
                'fixture_generated_by' => 'DumpedRailers',
              },
            "__article_#{article1.id}" => {
              'title'  => article1.title,
              'writer' => "__author_#{author1.id}",
            },
            "__article_#{article2.id}" => {
              'title'  => article2.title,
              'writer' => "__author_#{author1.id}",
            },
            "__article_#{article3.id}" => {
              'title'  => article3.title,
              'writer' => "__author_#{author2.id}",
            },
          }
        )
      end
    end

    context 'with default settings' do
      before do
        File.delete(*Dir['spec/tmp/*.yml'])
        DumpedRailers.dump!(*models, base_dir: 'spec/tmp')
      end

      describe 'authors fixture' do
        let(:fixture_file) { 'spec/tmp/authors.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has the same attributes that the original records have' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Author',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__author_#{author1.id}" => {
                'name' => author1.name
              },
              "__author_#{author2.id}" => {
                'name' => author2.name
              },
            },
          )
        end
      end

      describe 'article fixture' do
        let(:fixture_file) { 'spec/tmp/articles.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has the same attributes that the original records have' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Article',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__article_#{article1.id}" => {
                'title'  => article1.title,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article2.id}" => {
                'title'  => article2.title,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article3.id}" => {
                'title'  => article3.title,
                'writer' => "__author_#{author2.id}",
              },
            }
          )
        end
      end
    end

    context 'when ignorable_columns are configured' do
      around do |example|
        DumpedRailers.configure do |config|
          config.ignorable_columns = %w[name created_at updated_at]
        end

        example.run

        # make sure that the remaining tests run under default settings
        DumpedRailers.configure_defaults!
      end

      before do
        File.delete(*Dir['spec/tmp/*.yml'])
        DumpedRailers.dump!(*models, base_dir: 'spec/tmp')
      end

      describe 'authors fixture' do
        let(:fixture_file) { 'spec/tmp/authors.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has the same attributes that the original records have' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Author',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__author_#{author1.id}" => {
                'id' => author1.id
              },
              "__author_#{author2.id}" => {
                'id' => author2.id
              },
            },
          )
        end
      end

      describe 'article fixture' do
        let(:fixture_file) { 'spec/tmp/articles.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has upcased attributes' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Article',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__article_#{article1.id}" => {
                'id' => article1.id,
                'title'  => article1.title,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article2.id}" => {
                'id' => article2.id,
                'title'  => article2.title,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article3.id}" => {
                'id' => article3.id,
                'title'  => article3.title,
                'writer' => "__author_#{author2.id}",
              },
            }
          )
        end
      end
    end

    context 'with custom preprocessors' do
      let(:masking) {
        -> (attrs, model) {
          attrs.transform_values { |val|
            model == Author ? '<MASKED>' : val
          }
        }
      }

      let(:upcasing) {
        -> (attrs, _model) {
          attrs.map { |key, val|
            key == 'title' ? ['upcased_title', val.upcase] : [key, val]
          }.to_h
        }
      }

      before do
        File.delete(*Dir['spec/tmp/*.yml'])
        DumpedRailers.dump!(*models, base_dir: 'spec/tmp', preprocessors: [masking, upcasing])
      end

      describe 'authors fixture' do
        let(:fixture_file) { 'spec/tmp/authors.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has masked attributes' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Author',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__author_#{author1.id}" => {
                'name' => '<MASKED>'
              },
              "__author_#{author2.id}" => {
                'name' => '<MASKED>'
              },
            },
          )
        end
      end

      describe 'article fixture' do
        let(:fixture_file) { 'spec/tmp/articles.yml' }

        it 'is persisted' do
          expect(File.exist?(fixture_file))
        end

        let(:fixture) { YAML.load_file(fixture_file) }

        it 'has upcased attributes' do
          expect(fixture).to match(
            {
              '_fixture' =>
                {
                  'model_class'          => 'Article',
                  'fixture_generated_by' => 'DumpedRailers',
                },
              "__article_#{article1.id}" => {
                'upcased_title'  => article1.title.upcase,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article2.id}" => {
                'upcased_title'  => article2.title.upcase,
                'writer' => "__author_#{author1.id}",
              },
              "__article_#{article3.id}" => {
                'upcased_title'  => article3.title.upcase,
                'writer' => "__author_#{author2.id}",
              },
            }
          )
        end
      end
    end

    describe 'import after dump (populating the original records)' do
      context 'when imported via raw fixture data' do
        let(:raw_fixtures) { DumpedRailers.dump!(*models) }

        subject { DumpedRailers.import!(raw_fixtures) }

        it 'populates the Author and Article records' do
          expect { subject }.to change { Author.count }.from(2).to(4)
            .and change { Article.count }.from(3).to(6)
        end

        it 'doubles the Author records that shares the same name' do
          subject

          expect(Author.where(name: author1.name).count).to eq 2
          expect(Author.where(name: author2.name).count).to eq 2
        end

        it 'doubles the Article records that shares the same title and author name' do
          subject

          expect(Article.joins(:writer).where(title: article1.title, authors: { name: author1.name } ).count).to eq 2
          expect(Article.joins(:writer).where(title: article2.title, authors: { name: author1.name } ).count).to eq 2
          expect(Article.joins(:writer).where(title: article3.title, authors: { name: author2.name } ).count).to eq 2
        end
      end

      context 'when imported via fixture files' do
        before do
          File.delete(*Dir['spec/tmp/*.yml'])
          DumpedRailers.dump!(*models, base_dir: 'spec/tmp')
        end

        subject { DumpedRailers.import!('spec/tmp') }

        it 'populates the Author and Article records' do
          expect { subject }.to change { Author.count }.from(2).to(4)
            .and change { Article.count }.from(3).to(6)
        end

        it 'doubles the Author records that shares the same name' do
          subject

          expect(Author.where(name: author1.name).count).to eq 2
          expect(Author.where(name: author2.name).count).to eq 2
        end

        it 'doubles the Article records that shares the same title and author name' do
          subject

          expect(Article.joins(:writer).where(title: article1.title, authors: { name: author1.name } ).count).to eq 2
          expect(Article.joins(:writer).where(title: article2.title, authors: { name: author1.name } ).count).to eq 2
          expect(Article.joins(:writer).where(title: article3.title, authors: { name: author2.name } ).count).to eq 2
        end
      end
    end
  end

  describe '.import!' do
    context 'with fixture files' do
      subject { DumpedRailers.import!(*paths) }
      let(:paths) { ['spec/fixtures/authors.yml', 'spec/fixtures/articles.yml'] }

      it 'generates corresponding records' do
        expect { subject }.to change { Author.count }.by(5).and change { Article.count }.by(8)
      end

      it 'generates author records' do
        subject

        expect(Author.all).to contain_exactly(
          have_attributes(
            name: 'Osamu Tezuka'
          ),
          have_attributes(
            name: 'J. K. Rowling'
          ),
          have_attributes(
            name: 'Hayao Miyazaki'
          ),
          have_attributes(
            name: 'Walt Disney'
          ),
          have_attributes(
            name: 'John Ronald Reuel Tolkien'
          ),
        )
      end

      it 'generates article records with proper associations' do
        subject

        expect(Article.all).to contain_exactly(
          have_attributes(
            title: 'Harry Potter',
            writer: have_attributes(
              name: 'J. K. Rowling'
            ),
          ),
          have_attributes(
            title: 'Princess Mononoke',
            writer: have_attributes(
              name: 'Hayao Miyazaki'
            ),
          ),
          have_attributes(
            title: 'Sprited Away',
            writer: have_attributes(
              name: 'Hayao Miyazaki'
            ),
          ),
          have_attributes(
            title: 'Alice in Wonderland',
            writer: have_attributes(
              name: 'Walt Disney'
            ),
          ),
          have_attributes(
            title: 'Peter Pan',
            writer: have_attributes(
              name: 'Walt Disney'
            ),
          ),
          have_attributes(
            title: 'The Lord of the Rings',
            writer: have_attributes(
              name: 'John Ronald Reuel Tolkien'
            ),
          ),
          have_attributes(
            title: 'Phoenix',
            writer: have_attributes(
              name: 'Osamu Tezuka'
            ),
          ),
          have_attributes(
            title: 'Black Jack',
            writer: have_attributes(
              name: 'Osamu Tezuka'
            ),
          ),
        )
      end
    end

    describe 'version number' do
      it 'has a version number' do
        expect(DumpedRailers::VERSION).not_to be nil
      end
    end

    describe 'configuration' do
      describe 'ignorable_columns' do
        subject { DumpedRailers.config.ignorable_columns }

        context 'default' do
          it { is_expected.to eq(%w(id created_at updated_at)) }
        end

        context 'when configured' do
          subject {
            DumpedRailers.configure { |config| 
              config.ignorable_columns += ['uuid', 'tenant_id', 'published_on']
            }
          }

          it 'updates configuration' do
            expect { subject }.to change { DumpedRailers.config.ignorable_columns }.to (a_collection_containing_exactly *%w(id created_at updated_at uuid tenant_id published_on))
          end
        end
      end

      describe 'any other options' do
        subject { DumpedRailers.config.a_random_option }

        context 'with default value' do
          it { is_expected.to be_nil }
        end

        context 'when configured' do
          subject {
            DumpedRailers.configure { |config|
              config.a_random_option = :new_value
            }
          }

          it 'updates configuration' do
            expect { subject }.to change { DumpedRailers.config.a_random_option }.to (:new_value)
          end
        end
      end

      describe 'preprocessors' do
        subject { DumpedRailers.config.preprocessors }

        let(:preprocessor_1) { -> (_model, _attrs) { {foo: :bar} } }
        let(:preprocessor_2) { -> (_model, _attrs) { {bar: :baz} } }

        context 'default' do
          it { is_expected.to be_empty }
        end

        context 'when configured' do
          subject {
            DumpedRailers.configure { |config|
              config.preprocessors = [preprocessor_1, preprocessor_2]
            }
          }

          context 'before .dump! is called' do
            it 'updates configuration' do
              expect { subject }.to change { DumpedRailers.config.preprocessors }.to([preprocessor_1, preprocessor_2])
            end
          end

          context 'when .dump! is called' do
            it 'updates configuration' do
              subject
              DumpedRailers.dump!

              expect(DumpedRailers.config.preprocessors).to match [
                be_an_instance_of(DumpedRailers::Preprocessor::StripIgnorables),
                preprocessor_1,
                preprocessor_2
              ]
            end
          end
        end
      end
    end

    context 'with in-memory fixtures' do
      subject { DumpedRailers.import!(fixtures) }

      let(:fixtures) {
        {
          'authors' => {
            '_fixture' =>
              {
                'model_class'          => 'Author',
                'fixture_generated_by' => 'DumpedRailers',
              },
            '__author_1' => {
              'name' => 'William Shakespeare',
            },
            '__author_2' => {
              'name' => 'Shikibu Murasaki',
            },
          },
          'articles'  =>  {
            '_fixture' =>
              {
                'model_class'          => 'Article',
                'fixture_generated_by' => 'DumpedRailers',
              },
            '__article_1' => {
              'title'  => 'Romeo and Juliet',
              'writer' => '__author_1'
            },
            '__article_2' => {
              'title'  => 'King Lear',
              'writer' => '__author_1'
            },
            '__article_3' => {
              'title'  => 'Genji Monogatari',
              'writer' => '__author_2'
            },
          }
        }
      }

      it 'generates corresponding records' do
        expect { subject }.to change { Author.count }.by(2).and change { Article.count }.by(3)
      end

      it 'generates author records' do
        subject

        expect(Author.all).to contain_exactly(
          have_attributes(
            name: 'William Shakespeare'
          ),
          have_attributes(
            name: 'Shikibu Murasaki'
          ),
        )
      end

      it 'generates article records with proper associations' do
        subject

        expect(Article.all).to contain_exactly(
          have_attributes(
            title: 'Romeo and Juliet',
            writer: have_attributes(
              name: 'William Shakespeare'
            ),
          ),
          have_attributes(
            title: 'King Lear',
            writer: have_attributes(
              name: 'William Shakespeare'
            ),
          ),
          have_attributes(
            title: 'Genji Monogatari',
            writer: have_attributes(
              name: 'Shikibu Murasaki'
            ),
          ),
        )
      end
    end
  end
end
