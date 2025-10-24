# frozen_string_literal: true

require 'sinatra'
require 'rack/contrib'
require 'sinatra/activerecord'
require 'json'

use Rack::JSONBodyParser

configure do
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

before { content_type :json }

after do
  response.headers['Message-For-Tyler'] = 'Bish bosh bash'
end

get '/' do
  err 404, 'Route does not exist'
end

# Collection Actions

get '/todos/?' do
  Todo.select(:id, :title).to_json
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
    if Todo.exists?(title: title, due: parsed_due)
      err 409, 'A todo with this title and due date already exists'
    end

    todo = Todo.new title: title, due: parsed_due, notes: notes
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
  unless params['title'] && params['due'] && params.key?('notes')
    err 422, 'You must include all fields for a PUT: `title`, `due` and `notes` must be present'
  end

  todo.title = params['title']             if params.key?('title')
  todo.due   = parse_date(params['due'])   if params.key?('due')
  todo.notes = params['notes']             if params.key?('notes')

  if todo.save!
    todo.to_json
  else
    err 500, 'Todo could not be updated in the database'
  end
end

patch '/todos/:id/?' do |id|
  todo = get_todo(id)

  todo.title = params['title']             if params.key?('title')
  todo.due   = parse_date(params['due'])   if params.key?('due')
  todo.notes = params['notes']             if params.key?('notes')

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
  body({ error_message: message.to_s }.to_json)
  halt code.to_i
end

def parse_date(date)
  Date.parse date
rescue ArgumentError => e
  err 422, 'Due Date must be an ISO 8601 String: YYYY-MM-DD'
end

def get_todo(id)
  Todo.find(id)
rescue ActiveRecord::RecordNotFound => e
  err 404, 'Todo item not found'
end
