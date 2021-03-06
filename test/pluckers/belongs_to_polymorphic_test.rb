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

  def test_it_ignores_non_cofigured_models
    @subject = Pluckers::Base.new(BlogPost.send(all_method), attributes: [:id], reflections: {
      subject: {
        :Author => { }
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
        else
          nil
        end

      expected
    }

  end

  def test_it_applies_scopes_for_the_configured_model
    @subject = Pluckers::Base.new(BlogPost.send(all_method), attributes: [:id], reflections: {
      subject: {
        :Author => { scope: Author.no_results },
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

  def test_it_fetches_the_required_attributes
    @subject = Pluckers::Base.new(BlogPost.send(all_method), attributes: [:id], reflections: {
      subject: {
        :Author => { attributes: [ :name ] },
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

  def test_it_renames_belongs_to_polymorphic_reflections
    @subject = Pluckers::Base.new(BlogPost.send(all_method), attributes: [:id], reflections: {
        subject: {
          :Author => { },
          :Category => { }
        }
      }, renames: { subject: :post_subject }
    )

    must pluck Proc.new {|p|
      expected = {
        id: p.id,
        subject_id: p.subject_id,
        subject_type: p.subject_type
      }

      expected[:post_subject] = case p.subject
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

  def test_it_feteches_the_polymorphic_has_many_inverse_relationship
    @subject = Pluckers::Base.new(Author.send(all_method), attributes: [:id], reflections: {
        subject_blog_posts: { }
      }
    )

    must pluck Proc.new {|a|
      {
        id: a.id,
        subject_blog_posts: a.subject_blog_posts.map {|p|
          {
            id: p.id,
            title: p.title,
            text: p.text,
            author_id: p.author_id,
            editor_id: p.editor_id,
            reviewed_by_id: p.reviewed_by_id,
            main_category_title: p.main_category_title,
            subject_id: p.subject_id,
            subject_type: p.subject_type
          }
        }
      }
    }
  end

  def test_it_feteches_the_polymorphic_has_one_inverse_relationship
    @subject = Pluckers::Base.new(Category.send(all_method), attributes: [:id], reflections: {
        main_subject_blog_post: { }
      }
    )

    must pluck Proc.new {|a|
      {
        id: a.id,
        main_subject_blog_post: a.main_subject_blog_post.nil? ? nil : {
          id: a.main_subject_blog_post.id,
          title: a.main_subject_blog_post.title,
          text: a.main_subject_blog_post.text,
          author_id: a.main_subject_blog_post.author_id,
          editor_id: a.main_subject_blog_post.editor_id,
          reviewed_by_id: a.main_subject_blog_post.reviewed_by_id,
          main_category_title: a.main_subject_blog_post.main_category_title,
          subject_id: a.main_subject_blog_post.subject_id,
          subject_type: a.main_subject_blog_post.subject_type
        }
      }
    }
  end


end
