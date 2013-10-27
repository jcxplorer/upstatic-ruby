require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = Dir.glob("test/**/test_*.rb")
end

task :default => :test
