ActiveRecord::Schema.define(version: 1) do
  create_table :authors, force: true do |t|
    t.string     :name, null: false
  end

  create_table :posts, force: true do |t|
    t.string     :title, null: false
    t.text       :body
    t.references :author
  end

  create_table :topics, force: true do |t|
    t.string     :label, null: false
  end

  create_table :post_topics, force: true do |t|
    t.references :post
    t.references :topic
  end
end

class Author  < ActiveRecord::Base
  has_many :posts
  validates :name, presence: true
end

class Post < ActiveRecord::Base
  belongs_to  :author
  has_many :post_topics
  has_many :topics, through: :post_topics
  validates :title, presence: true
end

class Topic < ActiveRecord::Base
  has_many :post_topics
  has_many :posts, through: :post_topics
  validates :label, presence: true
end

class PostTopic < ActiveRecord::Base
  belongs_to :post
  belongs_to :topic
end
