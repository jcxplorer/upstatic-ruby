require "cases/helper"

class TestGzip < Upstatic::TestCase

  def self.config
    return @config if @config

    @config = Upstatic::Configuration.new
    @config.gzip_extensions ".html", ".css"
    @config
  end

  def config
    self.class.config
  end

  def request(uri, headers={})
    headers.merge!("Accept-Encoding" => "identity")
    super
  end

  def setup
    super
    deploy :gzip, config
  end

  def test_gzips_specified_files
    response = request("index.html")
    assert_gzipped response.body
    assert_equal "gzip", response["Content-Encoding"]

    response = request("folder/index.html")
    assert_gzipped response.body
    assert_equal "gzip", response["Content-Encoding"]

    response = request("styles.css")
    assert_gzipped response.body
    assert_equal "gzip", response["Content-Encoding"]
  end

  def test_does_not_gzip_other_files
    response = request("scripts.js")
    refute_gzipped response.body
    assert_nil response["Content-Encoding"]
  end

  def test_compresses_content_correctly
    response = request("index.html")

    io = StringIO.new(response.body)
    gz = Zlib::GzipReader.new(io)

    assert_equal "UPSTATIC_HTML", gz.read.strip
  end

end
