RSpec.describe ActiveModel, type: :model do

  require 'active_record_models'

  let(:author)     { Author.create(name: 'John Doe') }
  let(:post)       { Post.create(title: 'title', body: 'body') }
  let(:topic)      { Topic.create(label: 'label') }

  before do
    post.topics = [topic]
  end

  subject { post }

  it 'has attributes' do
    expect(post).to have_attributes(title: 'title', body: 'body')
  end
end
