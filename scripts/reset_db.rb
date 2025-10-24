#!/usr/bin/env ruby
# frozen_string_literal: true

# Reset script - deletes all todos from the database

require_relative '../app'

puts "Deleting all todos from the database..."

count = Todo.count
Todo.destroy_all

puts "Done! Deleted #{count} todo(s)."
