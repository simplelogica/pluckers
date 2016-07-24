ActiveRecord::Schema.define do
  self.verbose = false

  create_table :references, :force => true do |t|
    t.string :title
    t.string :url
    t.integer :blog_post_id
  end
end

class Reference < ActiveRecord::Base
  belongs_to :blog_post
end
