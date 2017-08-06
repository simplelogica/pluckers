ActiveRecord::Schema.define do
  self.verbose = false


  create_table :blog_posts_categories, :force => true, id: false do |t|
    t.string :blog_post_id
    t.text :category_id
  end

  create_table :categories, :force => true do |t|
    t.string :title
    t.string :image
  end
end

class Category < ActiveRecord::Base
  has_and_belongs_to_many :blog_posts
  has_one :main_subject_blog_post, class_name: "BlogPost", as: :subject
end
