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
    visit('/en/open-review/introduction/lists/')
    assert_equal 200, page.status_code
    assert_equal "30px", page.evaluate_script("jQuery('section ol').css('marginBottom');")
  end

  def test_intro_toc
    visit('/en/open-review/introduction/')
    assert_equal 200, page.status_code
    assert_equal "10px", page.evaluate_script("jQuery('#page-wrapper ul').css('marginBottom');")
  end

  def test_blockquote_paragraph_margin
    visit('/en/open-review/introduction/blockquotes/')
    assert_equal 200, page.status_code
    assert_equal "0px", page.evaluate_script("jQuery('blockquote p').css('marginBottom');")
  end

  def test_blockquote_list_margin
    visit('/en/open-review/introduction/blockquotes/')
    assert_equal 200, page.status_code
    assert_equal "0px", page.evaluate_script("jQuery('blockquote ol').css('marginBottom');")
  end

  def test_figures_are_centered
    visit('/en/open-review/introduction/figures/')
    assert_equal 200, page.status_code
    # test offset left to verify that image is not left aligned.
    image_offset_left = page.evaluate_script("jQuery('figure:last img').get(0).offsetLeft;")
    parent_offset_left = page.evaluate_script("jQuery('figure:last img').parent().get(0).offsetLeft;")
    assert image_offset_left > parent_offset_left
    assert_equal "center", page.evaluate_script("jQuery('figure').css('text-align');")
  end
end
