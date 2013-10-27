require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/lib/upstatic/compat.rb"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "upstatic"

require "minitest/autorun"
require "webmock/minitest"
require "upstatic/quiet_shell"

Minitest.after_run do
  AWS::S3.new.buckets.each { |b| b.delete! if b.name =~ /^upstatic-test-/ }
end

WebMock.allow_net_connect!

Upstatic.shell = Upstatic::QuietShell.new
