ActiveRecord::Schema.define(version: Time.now) do
  create_table :authors, force: true do |t|
    t.string     :name, null: false
  end

  create_table :articles, force: true do |t|
    t.references :author
    t.string     :title, null: false
  end

  create_table :content_holders, force: true do |t|
    t.references :article, null: true
    t.references :content, polymorphic: true, index: { unique: true }
  end

  create_table :text_contents, force: true do |t|
    t.string   :body, null: false
  end

  create_table :picture_contents, force: true do |t|
    t.json     :file, null: false
  end

  create_table :video_contents, force: true do |t|
    t.json     :file, null: false
  end
end

class Author  < ActiveRecord::Base
  has_many  :articles
  has_many  :content_holders, through: :articles
  validates :name, presence: true
end

class Article < ActiveRecord::Base
  belongs_to :writer, class_name: :Author, foreign_key: :author_id
  has_many :content_holders

  validates :title, presence: true
end

class ContentHolder < ActiveRecord::Base
  belongs_to :article, optional: true
  belongs_to :content, polymorphic: true

  validates :content_id, uniqueness: { scope: [:content_type] }
end

class TextContent < ActiveRecord::Base
  has_one :content_holder, as: :content
end

class PictureContent < ActiveRecord::Base
  has_one :content_holder, as: :content
end

class VideoContent < ActiveRecord::Base
  has_one :content_holder, as: :content
end
