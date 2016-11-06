require 'test_helper'

class HasManyThroughTest < test_base_class

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
        author_id: Author.where(name: 'Author 1').first.id
      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        author_id: Author.where(name: 'Author 2').first.id
      },
      {
        title: 'Test title 3',
        text: 'Test text 3'
      }
    ]
    BlogPost.create! @post_data


    @reference_data = [
      {
        title: 'Reference 1',
        url: 'reference1.es',
        blog_post_id: BlogPost.where(title: 'Test title 1').first.id
      },
      {
        title: 'Reference 2',
        url: 'reference2.es',
        blog_post_id: BlogPost.where(title: 'Test title 1').first.id
      },
      {
        title: 'Reference 3',
        url: 'reference3.es',
        blog_post_id: BlogPost.where(title: 'Test title 2').first.id
      },
      {
        title: 'Reference 4',
        url: 'reference4.es',
        blog_post_id: BlogPost.where(title: 'Test title 3').first.id
      }
    ]

    Reference.create! @reference_data

  end

  def teardown
    Author.delete_all
    BlogPost.delete_all
    Reference.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(Author.scoped, reflections: { references: {} })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        references: a.blog_posts.map {|p|
          p.references.map {|r|
            {
              id: r.id,
              title: r.title,
              url: r.url,
              blog_post_id: p.id
            }
          }
        }.flatten
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(Author.scoped, reflections: { references: { attributes: [:title] } })

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        references: a.blog_posts.map {|p|
          p.references.map {|r|
            {
              id: r.id,
              title: r.title,
              blog_post_id: p.id
            }
          }
        }.flatten
      }
    }

  end

  def test_it_renames_the_reflection
    @subject = Pluckers::Base.new(Author.scoped, reflections: { references: { attributes: [:title] } }, renames: { references: :bibliography})

    must pluck Proc.new {|a|
      {
        id: a.id,
        name: a.name,
        email: a.email,
        bibliography: a.blog_posts.map {|p|
          p.references.map {|r|
            {
              id: r.id,
              title: r.title,
              blog_post_id: p.id
            }
          }
        }.flatten
      }
    }

  end
end
