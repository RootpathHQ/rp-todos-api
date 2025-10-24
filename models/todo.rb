# frozen_string_literal: true

class Todo < ActiveRecord::Base
  validates :title, presence: true, length: { maximum: 200 }
  validates :notes, length: { maximum: 1000 }
  validates :due, presence: true
end
