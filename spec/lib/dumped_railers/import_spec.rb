# frozen_string_literal: true

RSpec.describe DumpedRailers::Import do

  let(:import_handler) { described_class.new(*paths) }

  subject { import_handler.import_all! }

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
          author: have_attributes(
            name: 'J. K. Rowling'
          ),
        ),
        have_attributes(
          title: 'Princess Mononoke',
          author: have_attributes(
            name: 'Hayao Miyazaki'
          ),
        ),
        have_attributes(
          title: 'Sprited Away',
          author: have_attributes(
            name: 'Hayao Miyazaki'
          ),
        ),
        have_attributes(
          title: 'Alice in Wonderland',
          author: have_attributes(
            name: 'Walt Disney'
          ),
        ),
        have_attributes(
          title: 'Peter Pan',
          author: have_attributes(
            name: 'Walt Disney'
          ),
        ),
        have_attributes(
          title: 'The Lord of the Rings',
          author: have_attributes(
            name: 'John Ronald Reuel Tolkien'
          ),
        ),
        have_attributes(
          title: 'Phoenix',
          author: have_attributes(
            name: 'Osamu Tezuka'
          ),
        ),
        have_attributes(
          title: 'Black Jack',
          author: have_attributes(
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
          author: have_attributes(
            name: 'J. K. Rowling'
          ),
        ),
        have_attributes(
          title: 'Princess Mononoke',
          author: have_attributes(
            name: 'Hayao Miyazaki'
          ),
        ),
        have_attributes(
          title: 'Sprited Away',
          author: have_attributes(
            name: 'Hayao Miyazaki'
          ),
        ),
        have_attributes(
          title: 'Alice in Wonderland',
          author: have_attributes(
            name: 'Walt Disney'
          ),
        ),
        have_attributes(
          title: 'Peter Pan',
          author: have_attributes(
            name: 'Walt Disney'
          ),
        ),
        have_attributes(
          title: 'The Lord of the Rings',
          author: have_attributes(
            name: 'John Ronald Reuel Tolkien'
          ),
        ),
        have_attributes(
          title: 'Phoenix',
          author: have_attributes(
            name: 'Osamu Tezuka'
          ),
        ),
        have_attributes(
          title: 'Black Jack',
          author: have_attributes(
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
