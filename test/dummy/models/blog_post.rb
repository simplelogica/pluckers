ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blog_posts, :force => true do |t|
    t.string :title
    t.text :text
    t.integer :author_id
  end
end

class BlogPost < ActiveRecord::Base
  belongs_to :author
  has_many :references
  has_and_belongs_to_many :categories
end
