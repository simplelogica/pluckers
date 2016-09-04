require 'test_helper'

class GlobalizeTest < Minitest::Test

  include PluckMatcher

  def setup
    @post_data = [
      {
        text: 'Test text 1',
        translations_attributes: [
          {
            locale: :es,
            translated_title: 'Test title 1 (ES)',
          },
          {
            locale: :en,
            translated_title: 'Test title 1 (EN)',
          }
        ]
      },
      {
        text: 'Test text 2',
        translations_attributes: [
          {
            locale: :es,
            translated_title: 'Test title 2 (ES)',
          },
          {
            locale: :en,
            translated_title: 'Test title 2 (EN)',
          }
        ]
      }
    ]
    BlogPost.create! @post_data
  end

  def teardown
    BlogPost.delete_all
  end

  def test_that_it_fetches_translated_attributes
    @subject = Pluckers::Base.new(BlogPost.all, attributes: [:translated_title])

    must pluck Proc.new {|p|
      {
        id: p.id,
        translated_title: p.translated_title
      }
    }

  end

  def test_that_it_fetches_attributes_with_locales
    @subject = Pluckers::Base.new(BlogPost.all, attributes_with_locale: { es: [:translated_title] })

    must pluck Proc.new {|p|
      {
        id: p.id,
        title: p.title,
        text: p.text,
        author_id: p.author_id,
        editor_id: p.editor_id,
        reviewed_by_id: p.reviewed_by_id,
        translated_title_es: p.translation_for(:es).translated_title
      }
    }

  end

  def test_it_renames_simple_attributes
    @subject = Pluckers::Base.new(BlogPost.all, attributes: [:translated_title], renames: { translated_title: :i18n_title })

    must pluck Proc.new {|p|
      {
        id: p.id,
        i18n_title: p.translated_title
      }
    }

  end
end
