ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blog_posts, force: true do |t|
    t.string :title
    t.text :text
    t.integer :author_id
    t.integer :editor_id
    t.integer :reviewed_by_id
  end

  create_table :blog_post_translations, force: true do |t|
    t.string :translated_title
    t.string :locale
    t.integer :blog_post_id
  end
end

class BlogPost < ActiveRecord::Base
  belongs_to :author
  belongs_to :editor, class_name: 'Author'
  belongs_to :reviewer, class_name: 'Author', foreign_key: 'reviewed_by_id'
  has_one :user, through: :author
  has_many :references
  has_and_belongs_to_many :categories

  translates :translated_title if const_defined?('Globalize')
end
