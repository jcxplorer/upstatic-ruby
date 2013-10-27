require "minitest_helper"

module Upstatic
  class TestCase < Minitest::Test
    REGION = "eu-west-1"
    ORIG_UPLOAD_DIR = File.expand_path("../../upload_dir", __FILE__)
    TEST_UPLOAD_DIR = File.expand_path("../../upload_dir_test", __FILE__)

    def setup
      FileUtils.rm_rf(TEST_UPLOAD_DIR)
      FileUtils.cp_r(ORIG_UPLOAD_DIR, TEST_UPLOAD_DIR)
    end

    def teardown
      FileUtils.rm_rf(TEST_UPLOAD_DIR)
    end

    def request(path, headers={})
      uri = URI("http://#{@@last_deployment}.s3-website-#{REGION}.amazonaws.com/#{path}")
      req = Net::HTTP::Get.new(uri.path)
      headers.each { |k,v| req[k] = v }
      Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
    end

    def deployments
      @@deployments ||= {}
    end

    def deploy(identifier, configuration, force=false)
      deployment = deployments[identifier]

      if !deployment || force
        unless configuration.bucket
          configuration.bucket "upstatic-test-#{SecureRandom.uuid}"
        end

        configuration.upload_dir TEST_UPLOAD_DIR
        configuration.region REGION

        Upstatic::Deployer.new(configuration).deploy!
        @@last_deployment = configuration.bucket
        deployments[identifier] = configuration.bucket
      else
        deployment
      end
    end

    def write_file(path, content)
      File.open(path, "w") { |f| f.write(content) }
    end

    def assert_gzipped(string)
      msg = "Expected string to be gzipped"
      assert string.bytes.first(2) == [0x1f, 0x8b], msg
    end

    def refute_gzipped(string)
      msg = "Expected string to not be gzipped"
      assert string.bytes.first(2) != [0x1f, 0x8b], msg
    end

    def assert_request_count(method, expected_count, &block)
      request_count = 0

      WebMock.after_request do |request_signature, response|
        request_count += 1 if request_signature.method == method
      end

      block.call

      WebMock.reset_callbacks

      assert_equal expected_count, request_count
    end
  end
end
