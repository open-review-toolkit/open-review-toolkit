require_relative 'tests_helper'

class TestSite < CapybaraTestCase
  def test_homepage
    visit("/")
    assert_equal 200, page.status_code
  end

  def test_not_found
    visit("/thispagedoesnotexist")
    assert_equal 404, page.status_code
  end

  def test_book_list
    visit('/en/introduction/lists/')
    assert_equal 200, page.status_code
    assert_equal "30px", page.evaluate_script("jQuery('.section ol').css('marginBottom');")
  end

  def test_intro_toc
    visit('/en/introduction/')
    assert_equal 200, page.status_code
    assert_equal "10px", page.evaluate_script("jQuery('#page-wrapper ul').css('marginBottom');")
  end
end
