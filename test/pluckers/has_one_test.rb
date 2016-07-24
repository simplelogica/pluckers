require 'test_helper'



class HasOneTest < Minitest::Test

  include PluckMatcher

  def setup
    @author_data = [
      {
        name: 'Author 1',
        email: 'author1@test.es'
      },
      {
        name: 'Author 2',
        email: 'author2@test.es'
      }
    ]

    authors = Author.create! @author_data

    @user_data = [
      {
        email: 'author1@test.es',
        password: 'password1',
        author_id: authors.first.id
      },
      {
        email: 'author2@test.es',
        password: 'password2',
        author_id: authors.last.id
      },
    ]
    User.create! @user_data
  end

  def teardown
    Author.delete_all
    User.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(Author.all, reflections: { user: {} })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        user: a.user.nil? ? nil : {
          id: a.user.id,
          email: a.user.email,
          password: a.user.password,
          author_id: a.id
        }
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(Author.all, reflections: { user: { attributes: [:email ]} })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        user: a.user.nil? ? nil : {
          id: a.user.id,
          email: a.user.email,
          author_id: a.id
        }
      }
    }

  end


  def test_it_renames_the_reflections
    @subject = Pluckers::Base.new(Author.all, reflections: { user: { attributes: [:email ]} }, renames: { user: :account })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        account: a.user.nil? ? nil : {
          id: a.user.id,
          email: a.user.email,
          author_id: a.id
        }
      }
    }

  end
end
