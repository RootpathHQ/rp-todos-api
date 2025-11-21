# frozen_string_literal: true

# Rakefile
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :db do
  task :load_config do
    require './app'
  end

  desc 'Clear all todos from database'
  task :clear do
    ruby 'scripts/reset_db.rb'
  end

  desc 'Reset and seed database (for deployments: set SEED_DB=true)'
  task :reset_and_seed do
    if ENV['SEED_DB'] == 'true'
      Rake::Task['db:seed'].invoke
      puts 'Database reset and seeded!'
    else
      puts 'Skipping seed (set SEED_DB=true to run)'
    end
  end
end

# Test task
RSpec::Core::RakeTask.new(:spec)

# Rubocop task
RuboCop::RakeTask.new

task default: :spec
task test: :spec
