# frozen_string_literal: true

require 'sinatra'
require 'rack/contrib'
require 'sinatra/activerecord'
require 'activemodel-serializers-xml'
require 'json'

use Rack::JSONBodyParser

configure do
  set :port, ENV['PORT'] || 4567
  set :bind, '0.0.0.0'
  set :allow_origin, :any
  set :allow_methods, %i[get post options delete put patch]
  enable :cross_origin

  # Load model
  require './models/todo'
end

options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,OPTIONS,DELETE,PATCH'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
end

before do
  # Set content type based on format from request path
  case request.path_info
  when /\.xml$/
    content_type :xml
  when /\.md$/
    content_type 'text/markdown'
  else
    content_type :json
  end
end

after do
  response.headers['Message-For-Tyler'] = 'Bish bosh bash'
end

get '/' do
  err 404, 'Route does not exist'
end

# Collection Actions

get '/todos(.:format)?' do
  format = params[:format]
  todos = format.nil? || format == 'json' ? Todo.select(:id, :title) : Todo.all
  render_response(todos, format)
end

# Accepts title, due and notes as querystring, form-data or JSON body
post '/todos/?' do
  title = params['title']
  due = params['due']
  notes = params['notes'] || ''

  if title && due
    # Easter egg: return 418 I'm a Teapot for educational purposes
    if title.downcase.include?('teapot')
      teapot_art = <<~TEAPOT
             ;,'
         _o_    ;--,
        ( o ) __|  _)
         '--`(___/
      TEAPOT

      response.headers['X-Teapot'] = 'Short and stout'
      body({
        error_message: "I'm a teapot and I refuse to brew coffee. Learn more: https://en.wikipedia.org/wiki/Hyper_Text_Coffee_Pot_Control_Protocol",
        teapot: teapot_art
      }.to_json)
      halt 418
    end

    # Check for duplicate todo (same title and due date)
    parsed_due = parse_date(due)
    err 409, 'A todo with this title and due date already exists' if Todo.exists?(title: title, due: parsed_due)

    todo = Todo.new title: title, due: parsed_due, notes: notes
    if todo.save
      status 201
      todo.to_json
    else
      # Validation failed - return helpful error message
      err 422, "Validation failed: #{todo.errors.full_messages.join(', ')}"
    end
  else
    err 422, 'You must provide `title` and `due` as a) QueryString parameters, b) form-data or c) JSON in the request body. The choice is yours.'
  end
end

put('/todos(.:format)?')    { err 405, 'You cannot modify the collection directly' }
patch('/todos(.:format)?')  { err 405, 'You cannot modify the collection directly' }
delete('/todos(.:format)?') { err 405, 'You cannot delete the collection' }

# Object Actions

get '/todos/:id(.:format)?' do |id, format|
  render_response(get_todo(id), format)
end

put '/todos/:id(.:format)?' do |id, _format|
  todo = get_todo(id)

  # Throw error if not all fields are present
  err 422, 'You must include all fields for a PUT: `title`, `due` and `notes` must be present' unless params['title'] && params['due'] && params.key?('notes')

  todo.title = params['title']
  todo.due   = parse_date(params['due'])
  todo.notes = params['notes']

  if todo.save
    todo.to_json
  else
    # Validation failed - return helpful error message
    err 422, "Validation failed: #{todo.errors.full_messages.join(', ')}"
  end
end

patch '/todos/:id(.:format)?' do |id, _format|
  todo = get_todo(id)

  todo.title = params['title']             if params.key?('title')
  todo.due   = parse_date(params['due'])   if params.key?('due')
  todo.notes = params['notes']             if params.key?('notes')

  if todo.save
    todo.to_json
  else
    # Validation failed - return helpful error message
    err 422, "Validation failed: #{todo.errors.full_messages.join(', ')}"
  end
end

delete '/todos/:id(.:format)?' do |id, _format|
  if get_todo(id).destroy
    halt 204
  else
    err 500, 'Todo could not be deleted'
  end
end

post('/todos/:id(.:format)?') { err 405, 'You cannot POST to this object' }

def render_response(data, format = nil)
  format ||= params[:format] || 'json'

  case format
  when 'xml'
    data.to_xml
  when 'md', 'markdown'
    render_markdown(data)
  else
    data.to_json
  end
end

def render_markdown(data)
  # Check if it's a collection (Array or ActiveRecord::Relation) vs a single record
  if data.is_a?(ActiveRecord::Relation) || data.is_a?(Array)
    # Collection of todos
    markdown = "# Todos\n\n"
    data.each do |todo|
      markdown += "- [#{todo.id}] #{todo.title}\n"
    end
    markdown
  else
    # Single todo
    markdown = "# #{data.title}\n\n"
    markdown += "**Due:** #{data.due}\n"
    markdown += "**Notes:** #{data.notes}\n" if data.respond_to?(:notes) && !data.notes.empty?
    markdown += "\n**Created:** #{data.created_at}\n" if data.respond_to?(:created_at)
    markdown += "**Updated:** #{data.updated_at}\n" if data.respond_to?(:updated_at)
    markdown
  end
end

def err(code, message)
  body({ error_message: message.to_s }.to_json)
  halt code.to_i
end

def parse_date(date)
  Date.parse date
rescue ArgumentError
  err 422, 'Due Date must be an ISO 8601 String: YYYY-MM-DD'
end

def get_todo(id)
  Todo.find(id)
rescue ActiveRecord::RecordNotFound
  err 404, 'Todo item not found'
end
