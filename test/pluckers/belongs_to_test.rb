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
        author_id: Author.find_by(name: 'Author 1').id,
        editor_id: Author.find_by(name: 'Author 2').id,
        reviewed_by_id: Author.find_by(name: 'Reviewer 2').id,
        main_category: categories.sample
      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        author_id: Author.find_by(name: 'Author 2').id,
        editor_id: Author.find_by(name: 'Author 1').id,
        reviewed_by_id: Author.find_by(name: 'Reviewer 1').id,
        main_category: categories.sample
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
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { author: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        author: p.author.nil? ? nil : {
          id: p.author.id,
          name: p.author.name,
          email: p.author.email
        }
      }
    }

  end

  def test_it_fetches_relationship_with_customized_class_name
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { editor: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        editor: p.editor.nil? ? nil : {
          id: p.editor.id,
          name: p.editor.name,
          email: p.editor.email
        }
      }
    }

  end

  def test_it_fetches_relationship_with_customized_foreign_key
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { reviewer: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        reviewer: p.reviewer.nil? ? nil : {
          id: p.reviewer.id,
          name: p.reviewer.name,
          email: p.reviewer.email
        }
      }
    }

  end

  def test_it_fetches_relationship_with_customized_primary_key
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { main_category: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        main_category: p.main_category.nil? ? nil : {
          id: p.main_category.id,
          title: p.main_category.title,
          image: p.main_category.image
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
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
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
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        post_author: p.author.nil? ? nil : {
          id: p.author.id,
          name: p.author.name
        }
      }
    }

  end
end
