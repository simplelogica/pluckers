require 'test_helper'

class SimpleAttributesTest < test_base_class

  include PluckMatcher

  def setup
    @post_data = [
      {
        title: 'Test title 1',
        text: 'Test text 1'
      },
      {
        title: 'Test title 2',
        text: 'Test text 2'
      }
    ]
    BlogPost.create! @post_data
  end

  def teardown
    BlogPost.delete_all
  end

  def test_that_it_fetches_model_attributes_when_no_attributes_are_configured
    @subject = Pluckers::Base.new(BlogPost.all)
    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: nil,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        main_category_title: p.main_category_title,
      }
    }
  end

  def test_that_it_fetches_only_required_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, attributes: [:text])

    must pluck Proc.new {|p|
      {
        id: p.id,
        text: p.text
      }
    }

  end

    def test_it_renames_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, attributes: [:text], renames: { text: :body })

    must pluck Proc.new {|p|
      {
        id: p.id,
        body: p.text
      }
    }

  end
end
