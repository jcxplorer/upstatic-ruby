require "securerandom"
require "mime/types"
require "zlib"
require "stringio"
require "upstatic/tool"
require "upstatic/manager"
require "upstatic/verifier"

module Upstatic
  class Deployer < Tool
    FORBIDDEN_FILENAMES = ["Upstatic"]

    def deploy!
      manager.create_bucket
      manager.configure_bucket

      Dir.chdir config.upload_dir do
        Dir["**/*"].each do |filename|
          upload(filename)
        end
      end

      perform_invalidation
      verifier.write_checksum_file

      @verifier = nil
      @invalidations = nil
    end

    private

    def manager
      @manager ||= Manager.new(config)
    end

    def verifier
      @verifier ||= Verifier.new(config)
    end

    def invalidations
      @invalidations ||= Set.new
    end

    def mark_to_invalidate(filename)
      if config.distribution_id
        invalidate_path("/#{filename}")

        if File.basename(filename) == "index.html"
          dirname = File.dirname(filename)

          if dirname == "."
            invalidate_path("/")
          else
            invalidate_path("/#{dirname}")
            invalidate_path("/#{dirname}/")
          end
        end
      end
    end

    def invalidate_path(path)
      if invalidations.add?(path)
        shell.say_status("invalidate", path, :cyan)
      end
    end

    def options_for_file(filename)
      extension = File.extname(filename)
      mime_type = MIME::Types.type_for(filename).first
      content_type = mime_type ? mime_type.content_type : nil

      file_options = {
        :file => filename,
        :acl => :public_read, 
        :content_type => content_type,
        :cache_control => config.default_cache_control
      }

      if cache_control = config.cache_controls[extension]
        file_options[:cache_control] = cache_control
      end

      if gzip_file?(filename)
        file_options.delete(:file)
        file_options[:content_encoding] = "gzip"
      end

      file_options
    end

    def gzip_file?(filename)
      extension = File.extname(filename)
      config.gzip_extensions.include?(extension)
    end

    def gzipped_file(filename)
      shell.say_status("gzip", filename, :yellow)

      io = StringIO.new("w")
      gz = Zlib::GzipWriter.new(io)
      gz.write(File.read(filename))
      gz.close

      io.string
    end

    def upload(filename)
      return unless File.file?(filename)
      return if FORBIDDEN_FILENAMES.include?(filename)

      options = options_for_file(filename)

      if verifier.stale?(filename, options)
        params = [options_for_file(filename)]

        if gzip_file?(filename)
          data = gzipped_file(filename)
          params.unshift(data)
        end

        shell.say_status("upload", filename, :green)
        bucket.objects[filename].write(*params)
        mark_to_invalidate(filename)
      else
        shell.say_status("identical", filename, :blue)
      end
    end

    def perform_invalidation
      return unless config.distribution_id
      return if invalidations.empty?

      cf.client.create_invalidation(
        :distribution_id => config.distribution_id,
        :invalidation_batch => {
          :paths => {
            :quantity => invalidations.count,
            :items => invalidations.to_a
          },
          :caller_reference => SecureRandom.uuid
        }
      )
    end
  end
end
