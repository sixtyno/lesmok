require "bundler/gem_tasks"

require 'rake/clean'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

CLEAN.add('pkg')

desc 'Run all examples'
RSpec::Core::RakeTask.new('spec')

