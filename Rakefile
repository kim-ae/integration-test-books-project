require 'rspec/core/rake_task'

task :tests => [:spec]

desc 'Task para execução dos specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/*-test.rb'
  t.rspec_opts = '--format documentation --format html --out reports/rspec_results.html'
  t.verbose = false
end