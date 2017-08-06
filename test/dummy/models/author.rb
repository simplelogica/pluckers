ActiveRecord::Schema.define do
  self.verbose = false

  create_table :authors, :force => true do |t|
    t.string :name
    t.string :email
  end
end

class Author < ActiveRecord::Base
  has_many :blog_posts
  has_many :references, through: :blog_posts
  has_one :user

  scope :no_results, ->() { where(false) }

end
