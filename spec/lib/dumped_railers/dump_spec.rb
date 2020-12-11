# frozen_string_literal: true

RSpec.describe DumpedRailers::Dump do
  describe '#build_fixtures!' do
    let(:fixture_generator) { described_class.new(*models, preprocessors: preprocessors) }

    subject { fixture_generator.build_fixtures! }

    let!(:author1)  { Author.create!(name: 'William Shakespeare') }
    let!(:author2)  { Author.create!(name: 'Shikibu Murasaki') }
    let!(:article1) { Article.create!(title: 'Romeo and Juliet', writer: author1) }
    let!(:article2) { Article.create!(title: 'King Lear',        writer: author1) }
    let!(:article3) { Article.create!(title: 'Genji Monogatari', writer: author2) }
    let(:models)    { [Author, Article] }

    let(:preprocessors) { [] }

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
end
