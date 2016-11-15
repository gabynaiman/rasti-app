require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
  t.warning = false
  t.loader = nil if ENV['TEST']
  ENV['TEST'], ENV['LINE'] = ENV['TEST'].split(':') if ENV['TEST'] && !ENV['LINE']
  t.options = ''
  t.options << "--name=/#{ENV['NAME']}/ " if ENV['NAME']
  t.options << "-l #{ENV['LINE']} " if ENV['LINE'] && ENV['TEST']
end

task default: :spec

desc 'Pry console'
task :console do
  require 'rasti-app'
  require 'pry'
  ARGV.clear
  Pry.start
end
