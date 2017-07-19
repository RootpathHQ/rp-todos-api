require 'sinatra'
require 'rack/contrib'
require 'sinatra/activerecord'
require 'json'

use Rack::PostBodyContentTypeParser

configure do
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options, :delete, :put, :patch]
  enable :cross_origin

  # Load model
  require './models/todo'
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,OPTIONS,DELETE,PATCH"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
end

before { content_type :json }

get '/' do
  err 404, 'Route does not exist'
end

# Collection Actions

get '/todos/?' do
  if Todo.count > 0
    Todo.select(:id, :title).to_json
  else
    err 400, 'There are no todos yet'
  end
end

# Accepts title, due and notes as querystring, form-data or JSON body
post '/todos/?' do
  title = params['title']
  due = params['due']
  notes = params['notes'] || ''

  if title && due
    todo = Todo.new title: title, due: parse_date(due), notes: notes
    if todo.save!
      status 201
      todo.to_json
    else
      err 500, 'Todo could not be saved in the database'
    end
  else
    err 422, 'You must provide `title` and `due` as a) QueryString parameters, b) form-data or c) JSON in the request body. The choice is yours.'
  end
end

put('/todos/?')    { err 405, 'You cannot modify the collection directly' }
patch('/todos/?')  { err 405, 'You cannot modify the collection directly' }
delete('/todos/?') { err 405, 'You cannot delete the collection' }


# Object Actions

get '/todos/:id/?' do |id|
  get_todo(id).to_json
end

put '/todos/:id/?' do |id|
  todo = get_todo(id)

  # Throw error if not all fields are present
  unless params['title'] && parse_date(params['due']) && params['notes']
    err 422, 'You must include all fields for a PUT: `title`, `due` and `notes` must be present'
  end

  todo.title = params['title']             if params.has_key?('title')
  todo.due   = parse_date(params['due'])   if params.has_key?('due')
  todo.notes = params['notes']             if params.has_key?('notes')

  if todo.save!
    todo.to_json
  else
    err 500, 'Todo could not be updated in the database'
  end
end

patch '/todos/:id/?' do |id|
  todo = get_todo(id)

  todo.title = params['title']             if params.has_key?('title')
  todo.due   = parse_date(params['due'])   if params.has_key?('due')
  todo.notes = params['notes']             if params.has_key?('notes')

  if todo.save!
    todo.to_json
  else
    err 500, 'Todo could not be updated in the database'
  end
end

delete '/todos/:id/?' do |id|
  if get_todo(id).destroy
    halt 204
  else
    err 500, 'Todo could not be deleted'
  end
end

post('/todos/:id/?') { err 405, 'You cannot POST to this object' }

private

def err(code, message)
  body({error_message: message.to_s}.to_json)
  halt code.to_i
end

def parse_date(date)
  Date.parse date
rescue ArgumentError => e
  err 422, 'Due Date must be and ISO 8601 String: YYYY-MM-DD'
end

def get_todo(id)
  Todo.find(id)
rescue ActiveRecord::RecordNotFound => e
  err 404, 'Todo item not found'
end
