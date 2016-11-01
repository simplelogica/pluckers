require 'test_helper'

class HasManyTest < test_base_class

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

    Author.create! @author_data

    @post_data = [
      {
        title: 'Test title 1',
        text: 'Test text 1',
        author_id: Author.find_by(name: 'Author 1').id
      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        author_id: Author.find_by(name: 'Author 2').id
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
    BlogPost.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(Author.all, reflections: { blog_posts: {} })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        blog_posts: a.blog_posts.map {|p|
          {
            id: p.id,
            title: p.title,
            text: p.text,
            author_id: p.author_id,
            editor_id: p.editor_id,
            reviewed_by_id: p.reviewed_by_id,
            main_category_title: p.main_category_title
          }
        }
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(Author.all, reflections: { blog_posts: { attributes: [:title ]} })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        blog_posts: a.blog_posts.map {|p|
          {
            id: p.id,
            title: p.title,
            author_id: p.author_id
          }
        }
      }
    }

  end

  def test_it_plucks_only_the_ids
    @subject = Pluckers::Base.new(Author.all, reflections: { blog_posts: { only_ids: true } })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        blog_post_ids: a.blog_post_ids
      }
    }

  end

  def test_it_renames_the_reflections
    @subject = Pluckers::Base.new(Author.all, reflections: { blog_posts: { attributes: [:title ]} }, renames: { blog_posts: :posts })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        posts: a.blog_posts.map {|p|
          {
            id: p.id,
            title: p.title,
            author_id: p.author_id
          }
        }
      }
    }

  end


  def test_it_renames_the_ids
    @subject = Pluckers::Base.new(Author.all, reflections: { blog_posts: { only_ids: true } }, renames: { blog_post_ids: :post_ids })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        post_ids: a.blog_post_ids
      }
    }

  end


end
