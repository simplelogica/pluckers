require 'test_helper'



class BelongsToTest < test_base_class

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
      },
      {
        name: 'Reviewer 1',
        email: 'Reviewer1@test.es'
      },
      {
        name: 'Reviewer 2',
        email: 'Reviewer2@test.es'
      }
    ]

    Author.create! @author_data

    @category_data = [
      {
        title: 'Category 1',
        image: 'image 1'
      },
      {
        title: 'Category 2',
        image: 'image 2'
      },
      {
        title: 'Category 3',
        image: 'image 3'
      },
      {
        title: 'Category 4',
        image: 'image 4'
      }
    ]

    categories = Category.create! @category_data

    @post_data = [
      {
        title: 'Test title 1',
        text: 'Test text 1',
        subject: Author.where(name: 'Author 1').first

      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        subject: Category.where(title: 'Category 2').first
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
    Category.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.send(all_method), attributes: [:id], reflections: {
      subject: {
        :Author => { },
        :Category => { }
      }
    })

    must pluck Proc.new {|p|
      expected = {
        id: p.id,
        subject_id: p.subject_id,
        subject_type: p.subject_type
      }

      expected[:subject] = case p.subject
        when Author
          {
            id: p.subject.id,
            name: p.subject.name,
            email: p.subject.email
          }
        when Category
          {
            id: p.subject.id,
            title: p.subject.title,
            image: p.subject.image
          }
        else
          nil
        end

      expected
    }

  end

end
