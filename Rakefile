# frozen_string_literal: true

# Rakefile
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

namespace :db do
  task :load_config do
    require './app'
  end
end

# Test task
RSpec::Core::RakeTask.new(:spec)

task default: :spec
task test: :spec
