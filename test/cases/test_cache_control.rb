require "cases/helper"

class TestCacheControl < Upstatic::TestCase

  def self.config
    return @config if @config

    @config = Upstatic::Configuration.new
    @config.default_cache_control "public, no-cache"
    @config.cache_control ".css", "public, max-age=3600"
    @config.cache_control ".js", "public, max-age=0"
    @config
  end

  def config
    self.class.config
  end

  def setup
    super
    deploy :cache_control, config
  end

  def test_sets_cache_control_for_css_file
    response = request("styles.css")
    assert_equal "public, max-age=3600", response["Cache-Control"]
  end

  def test_sets_cache_control_for_css_file
    response = request("scripts.js")
    assert_equal "public, max-age=0", response["Cache-Control"]
  end

  def test_sets_default_cache_control_for_other_files
    response = request("index.html")
    assert_equal "public, no-cache", response["Cache-Control"]
  end

end
