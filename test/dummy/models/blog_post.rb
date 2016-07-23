ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blog_posts, :force => true do |t|
    t.string :title
    t.text :text
  end
end

class BlogPost < ActiveRecord::Base

end
