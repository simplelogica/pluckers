require 'test_helper'



class HasAndBelongsToManyTest < Minitest::Test

  include PluckMatcher

  def setup
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

    # We have to sort the cateories to insert due to random sort issues with
    # the plucked results and the expected ones
    @post_data = [
      {
        title: 'Test title 1',
        text: 'Test text 1',
        categories: categories.sample(2).sort_by(&:id)
      },
      {
        title: 'Test title 2',
        text: 'Test text 2',
        categories: categories.sample(2).sort_by(&:id)
      },
      {
        title: 'Test title 3',
        text: 'Test text 3',
        categories: categories.sample(2).sort_by(&:id)
      }
    ]
    BlogPost.create! @post_data
  end

  def teardown
    Category.delete_all
    BlogPost.delete_all
  end

  def test_it_fetches_all_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: {} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        category_ids: p.category_ids,
        categories: p.categories.map {|c|
          {
            id: c.id,
            title: c.title,
            image: c.image
          }
        }
      }
    }

  end

  def test_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: { attributes: [:title ]} })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        category_ids: p.category_ids,
        categories: p.categories.map {|c|
          {
            id: c.id,
            title: c.title
          }
        }
      }
    }

  end

  def test_it_plucks_only_the_ids
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: { only_ids: true } })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        category_ids: p.category_ids
      }
    }

  end

  def test_it_renames_the_reflection
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: { attributes: [:title ]} }, renames: { categories: :tags })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        category_ids: p.category_ids,
        tags: p.categories.map {|c|
          {
            id: c.id,
            title: c.title
          }
        }
      }
    }

  end

  def test_it_renames_the_ids
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: { only_ids: true } }, renames: { category_ids: :c_ids })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        c_ids: p.category_ids
      }
    }

  end

  def test_it_renames_both
    @subject = Pluckers::Base.new(BlogPost.all, reflections: { categories: { attributes: [:title ]} }, renames: { categories: :tags, category_ids: :c_ids })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
        c_ids: p.category_ids,
        tags: p.categories.map {|c|
          {
            id: c.id,
            title: c.title
          }
        }
      }
    }

  end
end
