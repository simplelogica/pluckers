require 'test_helper'



class BelongsToTest < Minitest::Test

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
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { author: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        author: p.author.nil? ? nil : {
          id: p.author.id,
          name: p.author.name,
          email: p.author.email
        }
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { author: { attributes: [:name ]} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        author: p.author.nil? ? nil : {
          id: p.author.id,
          name: p.author.name
        }
      }
    }

  end

  def test_it_renames_belongs_to_reflections
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { author: { attributes: [:name ]}}, renames: { author: :post_author } )

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        post_author: p.author.nil? ? nil : {
          id: p.author.id,
          name: p.author.name
        }
      }
    }

  end
end
