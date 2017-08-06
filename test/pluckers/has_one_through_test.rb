require 'test_helper'

class HasOneThroughTest < test_base_class

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

    users = User.create! @user_data

    @post_data = [
      {
        title: 'Test title 1',
        text: 'Test text 1',
        author_id: authors.sample.id
      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        author_id: authors.sample.id
      },
      {
        title: 'Test title 3',
        text: 'Test text 3'
      }
    ]
    BlogPost.create! @post_data
  end

  def teardown
    Author.delete_all
    User.delete_all
    BlogPost.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.send(all_method), reflections: { user: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        subject_id: p.subject_id,
        subject_type: p.subject_type,
        user: p.user.nil? ? nil : {
          id: p.user.id,
          email: p.user.email,
          password: p.user.password,
          author_id: p.user.author_id
        }
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.send(all_method), reflections: { user: { attributes: [:email ]} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        subject_id: p.subject_id,
        subject_type: p.subject_type,
        user: p.user.nil? ? nil : {
          id: p.user.id,
          email: p.user.email,
          author_id: p.user.author_id
        }
      }
    }

  end

  def test_it_renames_the_reflection
    @subject = Pluckers::Base.new(BlogPost.send(all_method), reflections: { user: { attributes: [:email ]} }, renames: { user: :account})

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        subject_id: p.subject_id,
        subject_type: p.subject_type,
        account: p.user.nil? ? nil : {
          id: p.user.id,
          email: p.user.email,
          author_id: p.user.author_id
        }
      }
    }

  end
end
