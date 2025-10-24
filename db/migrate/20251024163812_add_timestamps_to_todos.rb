# frozen_string_literal: true

class AddTimestampsToTodos < ActiveRecord::Migration[8.1]
  def change
    add_timestamps :todos, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
