require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :build do |t, args|
  puts "packaging gem"
  system "gem build foucault_http.gemspec"
end

task :push, [:version] do |t, args|
  if args[:version]
    puts "pushing gem"
    system "gem push foucault_http-#{args[:version]}.gem"
  else
    puts "Please provide version"
  end
end
