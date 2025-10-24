# frozen_string_literal: true

# Reset database first
load File.join(__dir__, '..', 'scripts', 'reset_db.rb')

puts 'Seeding database with sample todos...'

todos = [
  {
    title: 'Watch Sunday Night Football',
    due: '2025-11-09',
    notes: 'Chiefs vs Bills - should be a good one'
  },
  {
    title: 'Check boat rigging before weekend',
    due: '2025-11-07',
    notes: 'Forecast looks perfect for sailing'
  },
  {
    title: 'Prep algebra tutoring session',
    due: '2025-11-06',
    notes: 'Review quadratic equations and word problems'
  },
  {
    title: 'Renew sailing club membership',
    due: '2025-11-15',
    notes: ''
  },
  {
    title: 'Update fantasy football roster',
    due: '2025-11-08',
    notes: 'Check injury reports before Thursday game'
  },
  {
    title: 'Order new life jackets',
    due: '2025-11-20',
    notes: ''
  }
]

todos.each do |todo_data|
  todo = Todo.create!(todo_data)
  puts "Created: #{todo.title}"
end

puts "\nSeeding complete! Created #{todos.count} todos."
