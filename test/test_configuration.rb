require "minitest_helper"

class TestConfiguration < Minitest::Test

  def setup
    super
    @config = Upstatic::Configuration.new
  end

  def test_reads_from_file
    path = File.expand_path("../upload_dir/Upstatic", __FILE__)
    config = Upstatic::Configuration.read(path)
    assert_equal "upstatic", config.bucket
  end

  def test_cache_control_sanitizes_extensions
    @config.cache_control "html", "public"
    assert_equal "public", @config.cache_controls[".html"]
  end

  def test_cache_control_accepts_symbols_as_extensions
    @config.cache_control :css, "public"
    assert_equal "public", @config.cache_controls[".css"]
  end

  def test_gzip_extensions_sanitizes_extensions
    @config.gzip_extensions :html, "css", ".js"
    assert @config.gzip_extensions.include?(".html")
    assert @config.gzip_extensions.include?(".css")
    assert @config.gzip_extensions.include?(".js")
  end

end
