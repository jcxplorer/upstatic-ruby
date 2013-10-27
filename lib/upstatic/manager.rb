require "upstatic/tool"

module Upstatic
  class Manager < Tool

    def create_bucket
      unless bucket.exists?
        shell.say_status "bucket", "creating '#{config.bucket}'"
        s3.buckets.create(config.bucket)
      end
    end

    def configure_bucket
      unless bucket.website_configuration
        shell.say_status "bucket", "configuring for website hosting"
        bucket.configure_website
      end
    rescue AWS::S3::Errors::NoSuchBucket
      # Can't find the newly created bucket yet. Let's wait a bit and retry.
      sleep(2)
      retry
    rescue AWS::S3::Errors::AccessDenied
      abort "We could not access the bucket '#{config.bucket}'.\n\n" <<
            "One of two things happened here:\n\n" <<
            "- You're trying to access a bucket that another user already\n" <<
            "  owns. Please note that the bucket namespace is shared by\n" <<
            "  all users of the system.\n" <<
            "- You actually own this bucket on some other account. If that\n" <<
            "  is the case, please check your credentials."
    end

  end
end
