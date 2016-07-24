ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :email
    t.string :password
    t.integer :author_id
  end
end

class User < ActiveRecord::Base
  belongs_to :author
end
