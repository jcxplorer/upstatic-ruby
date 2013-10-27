require "aws-sdk"
require "upstatic/configuration"

module Upstatic
  class Tool

    def initialize(configuration)
      @configuration = configuration
    end

    private

    def config
      @configuration
    end

    def s3
      @s3 ||= AWS::S3.new(
        :access_key_id => config.access_key_id,
        :secret_access_key => config.secret_access_key,
        :region => config.region
      )
    end

    def bucket
      @bucket ||= s3.buckets[config.bucket]
    end

    def cf
      @cf ||= AWS::CloudFront.new(
        :access_key_id => config.access_key_id,
        :secret_access_key => config.secret_access_key
      )
    end

    def shell
      Upstatic.shell
    end
  end
end
