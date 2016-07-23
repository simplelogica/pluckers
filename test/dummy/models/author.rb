ActiveRecord::Schema.define do
  self.verbose = false

  create_table :authors, :force => true do |t|
    t.string :name
    t.string :email
  end
end

class Author < ActiveRecord::Base
  has_many :authors
end
