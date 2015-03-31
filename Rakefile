require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run tests for all ORMs.'
task default: :test

desc 'Run unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = false
end

task :default => :test

require 'rdoc/task'
$:.push File.expand_path('../lib', __FILE__)
require 'devise_security_extension/version'
Rake::RDocTask.new do |rdoc|
  version = DeviseSecurityExtension::VERSION.dup

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "devise_security_extension #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
