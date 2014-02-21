require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.warning = false
  test.verbose = true
end

task :default => :test

task :benchmark do
  Dir.glob('benchmark/**/benchmark_*.rb').each do |benchmark|
    require_relative benchmark
  end
end
