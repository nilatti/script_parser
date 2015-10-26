require 'rake/testtask'
require 'test/unit'
#require 'rubygems'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end