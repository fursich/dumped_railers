# frozen_string_literal: true

RSpec.describe DumpedRailers::Import do
  describe '#import_all!' do
    let(:import_handler) {
      described_class.new(
        *paths,
        authorized_models: authorized_models,
      )
    }

    subject { import_handler.import_all! }
    context 'with full authorization' do
      let(:authorized_models) { :any }

      context 'with fixture file paths' do
        context 'with files that satisfies dependencies' do
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

        context 'with files that lack dependent records' do
          let(:paths) {
            [
              'spec/fixtures/content_holders.yml',
              'spec/fixtures/text_contents.yml',
              'spec/fixtures/picture_contents.yml',
              'spec/fixtures/video_contents.yml',
            ]
          }

          it 'raises RuntimeError' do
            expect { subject }.to raise_error RuntimeError
          end
        end

        context 'with a directory' do
          let(:paths) { ['spec/fixtures/'] }

          it 'generates corresponding records' do
            expect { subject }.to change { Author.count }.by(5)
              .and change { Article.count }.by(8)
              .and change { ContentHolder.count }.by(15)
              .and change { TextContent.count }.by(9)
              .and change { PictureContent.count }.by(3)
              .and change { VideoContent.count }.by(3)
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

          it 'generates content holders' do
            subject

            expect(ContentHolder.all).to contain_exactly(
              have_attributes(
                article: have_attributes(
                  title: 'The Lord of the Rings',
                ),
                content: have_attributes(
                  body: "Where there's life there's hope, and need of vittles."
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Black Jack',
                ),
                content: have_attributes(
                  body: "I don't know his real name, but they call him Black Jack."
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Alice in Wonderland',
                ),
                content: have_attributes(
                  body: 'This is an unbirthday party!'
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Princess Mononoke',
                ),
                content: have_attributes(
                  body: 'To see with eyes unclouded by hate.'
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Princess Mononoke',
                ),
                content: have_attributes(
                  body: 'You see everyone wants everything, that’s the way the world is.'
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Phoenix',
                ),
                content: have_attributes(
                  body: "Life? Death? It's all meaningless!"
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Harry Potter',
                ),
                content: have_attributes(
                  body: 'Of course it is happening inside your head, Harry, but why on earth should that mean that it is not real?'
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Alice in Wonderland',
                ),
                content: have_attributes(
                  body: 'But how can one possibly pay attention to a book with no pictures in it?'
                ),
              ),
              have_attributes(
                content: have_attributes(
                  body: 'Our greatest natural resource is the minds of our children.'
                ),
              ),
              have_attributes(
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/the_hobbit/98x45672a.jpg',
                    'metadata' => {
                      'size' => 193450,
                      'filename' => 'hobit.jpg',
                    }
                  }
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Princess Mononoke',
                ),
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/princess_mononoke/98q3r28289s.png',
                    'metadata' => {
                      'size' => 1230890,
                      'filename' => 'haku.png',
                    }
                  }
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Phoenix',
                ),
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/phoenix/98m298sm912.jpg',
                    'metadata' => {
                      'size' => 823890,
                      'filename' => 'phoenix.jpg',
                    }
                  }
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Peter Pan',
                ),
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/peter_pan/9382sjdf8.mp4',
                    'metadata' => {
                      'size' => 9178348,
                      'filename' => 'peter_and_wendy.mp4',
                    }
                  }
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Harry Potter',
                ),
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/harry_potter/e9128347l.mp4',
                    'metadata' => {
                      'size' => 41735021,
                      'filename' => 'hogwarts.mp4',
                    }
                  }
                ),
              ),
              have_attributes(
                article: have_attributes(
                  title: 'Sprited Away',
                ),
                content: have_attributes(
                  file: {
                    'url' => 'https://example.com/storage/spritted_away/i012387413a.mp4',
                    'metadata' => {
                      'size' => 9747403,
                      'filename' => 'yubaba.mp4',
                    }
                  }
                ),
              ),
            )
          end

          it 'generates text contents' do
            subject

            expect(TextContent.all).to contain_exactly(
              have_attributes(
                body: "Where there's life there's hope, and need of vittles."
              ),
              have_attributes(
                body: "I don't know his real name, but they call him Black Jack."
              ),
              have_attributes(
                body: 'This is an unbirthday party!'
              ),
              have_attributes(
                body: 'To see with eyes unclouded by hate.'
              ),
              have_attributes(
                body: 'You see everyone wants everything, that’s the way the world is.'
              ),
              have_attributes(
                body: "Life? Death? It's all meaningless!"
              ),
              have_attributes(
                body: 'Of course it is happening inside your head, Harry, but why on earth should that mean that it is not real?'
              ),
              have_attributes(
                body: 'But how can one possibly pay attention to a book with no pictures in it?'
              ),
              have_attributes(
                body: 'Our greatest natural resource is the minds of our children.'
              ),
            )
          end

          it 'generates picture contents' do
            subject

            expect(PictureContent.all).to contain_exactly(
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/the_hobbit/98x45672a.jpg',
                  'metadata' => {
                    'size' => 193450,
                    'filename' => 'hobit.jpg',
                  }
                }
              ),
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/princess_mononoke/98q3r28289s.png',
                  'metadata' => {
                    'size' => 1230890,
                    'filename' => 'haku.png',
                  }
                }
              ),
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/phoenix/98m298sm912.jpg',
                  'metadata' => {
                    'size' => 823890,
                    'filename' => 'phoenix.jpg',
                  }
                }
              ),
            )
          end

          it 'generates video contents' do
            subject

            expect(VideoContent.all).to contain_exactly(
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/peter_pan/9382sjdf8.mp4',
                  'metadata' => {
                    'size' => 9178348,
                    'filename' => 'peter_and_wendy.mp4',
                  }
                }
              ),
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/harry_potter/e9128347l.mp4',
                  'metadata' => {
                    'size' => 41735021,
                    'filename' => 'hogwarts.mp4',
                  }
                }
              ),
              have_attributes(
                file: {
                  'url' => 'https://example.com/storage/spritted_away/i012387413a.mp4',
                  'metadata' => {
                    'size' => 9747403,
                    'filename' => 'yubaba.mp4',
                  }
                }
              ),
            )
          end
        end
      end

      context 'with in-memory fixtures' do
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
        let(:paths) { [fixtures] }

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

    describe 'callbacks' do
      let(:import_handler) {
        described_class.new(
          *paths,
          authorized_models: :any,
          before_save: before_callbacks,
          after_save:  after_callbacks,
        )
      }

      let(:paths) { ['spec/fixtures/authors.yml', 'spec/fixtures/articles.yml'] }
      let(:before_callbacks) { [] }
      let(:after_callbacks)  { [] }

      describe 'before_save' do
        let(:before_callbacks) { [before_callback1, before_callback2] }

        let(:before_callback1) {
          -> (model, records) {
            if model == Author
              records.each do |record|
                record.name = "-- #{record.name} --"
              end
            end
          }
        }
        let(:before_callback2) {
          -> (model, records) {
            if model == Article
              records.each do |record|
                record.title = "<< #{record.title} >>"
              end
            end
          }
        }

        it 'does not raise RuntimeError' do
          expect { subject }.not_to raise_error
        end

        it 'generates corresponding records' do
          expect { subject }.to change { Author.count }.by(5).and change { Article.count }.by(8)
        end

        it 'generates author records' do
          subject

          expect(Author.all).to contain_exactly(
            have_attributes(
              name: '-- Osamu Tezuka --'
            ),
            have_attributes(
              name: '-- J. K. Rowling --'
            ),
            have_attributes(
              name: '-- Hayao Miyazaki --'
            ),
            have_attributes(
              name: '-- Walt Disney --'
            ),
            have_attributes(
              name: '-- John Ronald Reuel Tolkien --'
            ),
          )
        end

        it 'generates article records with proper associations' do
          subject

          expect(Article.all).to contain_exactly(
            have_attributes(
              title: '<< Harry Potter >>',
              writer: have_attributes(
                name: '-- J. K. Rowling --'
              ),
            ),
            have_attributes(
              title: '<< Princess Mononoke >>',
              writer: have_attributes(
                name: '-- Hayao Miyazaki --'
              ),
            ),
            have_attributes(
              title: '<< Sprited Away >>',
              writer: have_attributes(
                name: '-- Hayao Miyazaki --'
              ),
            ),
            have_attributes(
              title: '<< Alice in Wonderland >>',
              writer: have_attributes(
                name: '-- Walt Disney --'
              ),
            ),
            have_attributes(
              title: '<< Peter Pan >>',
              writer: have_attributes(
                name: '-- Walt Disney --'
              ),
            ),
            have_attributes(
              title: '<< The Lord of the Rings >>',
              writer: have_attributes(
                name: '-- John Ronald Reuel Tolkien --'
              ),
            ),
            have_attributes(
              title: '<< Phoenix >>',
              writer: have_attributes(
                name: '-- Osamu Tezuka --'
              ),
            ),
            have_attributes(
              title: '<< Black Jack >>',
              writer: have_attributes(
                name: '-- Osamu Tezuka --'
              ),
            ),
          )
        end
      end

      describe 'after_save' do
        let(:after_callbacks) { [after_callback1, after_callback2] }
        let(:after_callback1) {
          -> (model, records) {
            if model == Article
              persisted_titles[model] = records.map(&:title)
            end
          }
        }
        let(:persisted_titles) { {} }

        let(:after_callback2) {
          -> (model, records) {
            persisted_ids[model] = records.map(&:id)
          }
        }
        let(:persisted_ids) { {} }

        it 'does not raise RuntimeError' do
          expect { subject }.not_to raise_error
        end

        it 'generates corresponding records' do
          expect { subject }.to change { Author.count }.by(5).and change { Article.count }.by(8)
        end

        it 'stores persisted records' do
          subject

          expect(persisted_titles).to match(
            Article => a_collection_containing_exactly(
              'Harry Potter',
              'Princess Mononoke',
              'Sprited Away',
              'Alice in Wonderland',
              'Peter Pan',
              'The Lord of the Rings',
              'Phoenix',
              'Black Jack',
            )
          )
        end

        it 'stores persisted records' do
          subject

          expect(persisted_ids).to match(
            {
              Author  => a_collection_containing_exactly(*Author.all.ids),
              Article => a_collection_containing_exactly(*Article.all.ids),
            }
          )
        end
      end
    end

    describe 'authorized_models' do
      context 'when authorization granted for all the imported models' do
        let(:authorized_models) { [Author, Article] }
        let(:paths) { ['spec/fixtures/authors.yml', 'spec/fixtures/articles.yml'] }

        it 'does not raise RuntimeError' do
          expect { subject }.not_to raise_error
        end

        it 'generates corresponding records' do
          expect { subject }.to change { Author.count }.by(5).and change { Article.count }.by(8)
        end
      end

      context 'when authorization missing for part of the imported models' do
        let(:authorized_models) { [Author] }
        let(:paths) { ['spec/fixtures/authors.yml', 'spec/fixtures/articles.yml'] }

        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end

        it 'does not generate any Author records' do
          expect { subject rescue nil }.not_to change { Author.count }
        end

        it 'does not generate any Article records' do
          expect { subject rescue nil }.not_to change { Article.count }
        end
      end

      context 'with no authorization' do
        let(:authorized_models) { [] }
        let(:paths) { ['spec/fixtures/authors.yml', 'spec/fixtures/articles.yml'] }

        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end

        it 'does not generate any Author records' do
          expect { subject rescue nil }.not_to change { Author.count }
        end

        it 'does not generate any Article records' do
          expect { subject rescue nil }.not_to change { Article.count }
        end
      end
    end
  end
end
