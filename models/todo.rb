# frozen_string_literal: true

class Todo < ActiveRecord::Base
  validates_presence_of :title, :due
end
