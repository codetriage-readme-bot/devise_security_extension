$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'
require 'rdoc/task'
require 'devise_security_extension/version'

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

Rake::RDocTask.new do |rdoc|
  version = DeviseSecurityExtension::VERSION.dup

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "devise_security_extension #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
