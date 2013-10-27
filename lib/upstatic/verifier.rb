require "digest/sha1"
require "upstatic/tool"

module Upstatic
  class Verifier < Tool

    def initialize(configuration)
      super

      @files = {}
      @file_options = {}

      @new_files = {}
      @new_file_options = {}

      bucket.objects[".sha1sums"].read.lines.each do |line|
        file_checksum, file_options_checksum, filename = line.split(" ", 3)
        filename.chomp!
        @files[filename] = file_checksum
        @file_options[filename] = file_options_checksum
      end
    rescue AWS::S3::Errors::NoSuchKey
      # Checksum file doesn't exist.
      # Both @files and @file_options will be empty, and that's ok.
      @has_no_data = true
    end

    def stale?(filename, write_options)
      return true if config.force_deploy

      file_options_checksum = Digest::SHA1.hexdigest(Marshal.dump(write_options))
      file_checksum = Digest::SHA1.file(filename).hexdigest

      @new_files[filename] = file_checksum
      @new_file_options[filename] = file_options_checksum

      if @files[filename] != file_checksum
        return true
      end

      if @file_options[filename] != file_options_checksum
        return true
      end

      return false
    end

    def write_checksum_file
      lines = []
      @new_files.each do |filename, checksum|
        file_option_checksum = @new_file_options[filename]
        lines << "#{checksum} #{file_option_checksum} #{filename}"
      end

      shell.say_status("upload", ".sha1sums", :green)
      bucket.objects[".sha1sums"].write(lines.join("\n"))
    end
  end
end
