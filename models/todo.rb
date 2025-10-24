# frozen_string_literal: true

class Todo < ActiveRecord::Base
  validates :title, :due, presence: true
end
