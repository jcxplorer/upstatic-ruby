require "upstatic/options"

module Upstatic
  class Configuration
    include Options

    option :bucket
    option :region
    option :access_key_id
    option :secret_access_key
    option :distribution_id
    option :default_cache_control, :default => "public, max-age=691200"
    option :upload_dir, :default => "."
    option :force_deploy, :default => false

    def gzip_extensions(*extensions)
      if extensions.count > 0
        @gzip_extensions = extensions.map { |ext| sanitize_extension(ext) }
      else
        @gzip_extensions ||= []
      end
    end

    def cache_controls
      @cache_controls ||= {}
    end

    def cache_control(extension, cache_control)
      cache_controls[sanitize_extension(extension)] = cache_control
    end

    def self.read(path)
      config = new
      config.instance_eval(File.read(path), path, 1)
      config
    end

    private

    def sanitize_extension(extension)
      extension.to_s.sub(/\A([^.])/, '.\1')
    end

  end
end
