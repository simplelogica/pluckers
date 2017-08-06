ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blog_posts, force: true do |t|
    t.string :title
    t.text :text
    t.integer :author_id
    t.integer :editor_id
    t.integer :reviewed_by_id
    t.string :main_category_title
    t.string :subject_type
    t.integer :subject_id
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
  belongs_to :main_category, class_name: 'Category', foreign_key: 'main_category_title', primary_key: 'title'
  belongs_to :subject, polymorphic: true
  has_one :user, through: :author
  has_many :references
  has_and_belongs_to_many :categories

  if const_defined?('Globalize')
    translates :translated_title
    accepts_nested_attributes_for :translations
  end
end
