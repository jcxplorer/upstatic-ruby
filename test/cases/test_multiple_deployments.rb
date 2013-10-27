require "cases/helper"

class TestMultipleDeployments < Upstatic::TestCase

  def self.config
    return @config if @config
    @config = Upstatic::Configuration.new
  end

  def config
    self.class.config
  end

  def setup
    super
    config.bucket nil
  end

  def test_do_not_upload_unchanged_files
    deploy :multiple_unchanged, config

    assert_request_count(:put, 1) do
      deploy :multiple_unchanged, config, true
    end
  end

  def test_upload_changed_files
    deploy :multiple_changed, config

    changed_file = File.join(TEST_UPLOAD_DIR, "folder/index.html")
    write_file(changed_file, "UPSTATIC_CHANGED")

    assert_request_count(:put, 2) do
      deploy :multiple_changed, config, true
    end

    response = request("folder/index.html")
    assert_equal "UPSTATIC_CHANGED", response.body.strip
  end

  def test_upload_added_files
    deploy :multiple_added, config

    new_file = File.join(TEST_UPLOAD_DIR, "new.html")
    write_file(new_file, "UPSTATIC_NEW")

    assert_request_count(:put, 2) do
      deploy :multiple_added, config, true
    end

    response = request("new.html")
    assert_equal "UPSTATIC_NEW", response.body.strip
  end

  def test_upload_modified_configuration_files
    deploy :muliple_config, config

    new_config = config.dup
    new_config.gzip_extensions ".html"

    assert_request_count(:put, 3) do
      deploy :multiple_config, new_config, true
    end

    response = request("index.html", "Accept-Encoding" => "identity")
    assert_gzipped response.body
    assert_equal "gzip", response["Content-Encoding"]

    response = request("folder/index.html", "Accept-Encoding" => "identity")
    assert_gzipped response.body
    assert_equal "gzip", response["Content-Encoding"]
  end

end
