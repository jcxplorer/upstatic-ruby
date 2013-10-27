require "cases/helper"

class TestDeployment < Upstatic::TestCase

  def self.config
    return @config if @config
    @config = Upstatic::Configuration.new
  end

  def config
    self.class.config
  end

  def setup
    super
    deploy :default, config
  end

  def test_deploys_html_file
    response = request("index.html")
    assert_equal "200", response.code
    assert_equal "UPSTATIC_HTML", response.body.strip
    assert_equal "text/html", response["Content-Type"]
    assert_equal "public, max-age=691200", response["Cache-Control"]
  end

  def test_deploys_css_file
    response = request("styles.css")
    assert_equal "200", response.code
    assert_equal "UPSTATIC_CSS", response.body.strip
    assert_equal "text/css", response["Content-Type"]
    assert_equal "public, max-age=691200", response["Cache-Control"]
  end

  def test_deploys_javascript_file
    response = request("scripts.js")
    assert_equal "200", response.code
    assert_equal "UPSTATIC_JS", response.body.strip
    assert_equal "application/javascript", response["Content-Type"]
    assert_equal "public, max-age=691200", response["Cache-Control"]
  end

  def test_deploys_folder
    response = request("folder/index.html")
    assert_equal "200", response.code
    assert_equal "UPSTATIC_FOLDER", response.body.strip
    assert_equal "text/html", response["Content-Type"]
    assert_equal "public, max-age=691200", response["Cache-Control"]
  end

  def test_does_not_make_checksum_file_public
    response = request(".sha1sums")
    assert_equal "403", response.code
  end

  def test_does_not_deploy_config_file
    response = request("Upstatic")
    assert_equal "403", response.code
  end

end
