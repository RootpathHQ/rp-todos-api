require 'spec_helper'

RSpec.describe 'Todos API' do
  let(:base_url) { API_BASE_URL }

  # Helper to clean up test todos after suite
  after(:all) do
    response = HTTParty.get("#{API_BASE_URL}/todos")
    if response.success?
      todos = JSON.parse(response.body)
      todos.each do |todo|
        HTTParty.delete("#{API_BASE_URL}/todos/#{todo['id']}")
      end
    end
  end

  describe 'GET /todos' do
    it 'returns list of todos' do
      response = HTTParty.get("#{base_url}/todos")

      expect(response.code).to eq(200)
      expect(response.headers['content-type']).to include('application/json')

      todos = JSON.parse(response.body)
      expect(todos).to be_an(Array)
    end
  end

  describe 'POST /todos' do
    it 'creates a new todo' do
      response = HTTParty.post("#{base_url}/todos",
        body: {
          title: 'Test Todo',
          due: '2025-12-31',
          notes: 'Test notes'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(response.code).to eq(201)

      todo = JSON.parse(response.body)
      expect(todo['title']).to eq('Test Todo')
      expect(todo['due']).to eq('2025-12-31')
      expect(todo['notes']).to eq('Test notes')
      expect(todo['id']).to be_a(Integer)
    end
  end

  describe 'GET /todos/:id' do
    it 'returns a single todo' do
      # Create a todo first
      create_response = HTTParty.post("#{base_url}/todos",
        body: { title: 'Get Me', due: '2025-12-31' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      todo_id = JSON.parse(create_response.body)['id']

      # Get the todo
      response = HTTParty.get("#{base_url}/todos/#{todo_id}")

      expect(response.code).to eq(200)

      todo = JSON.parse(response.body)
      expect(todo['id']).to eq(todo_id)
      expect(todo['title']).to eq('Get Me')
    end
  end

  describe 'PATCH /todos/:id' do
    it 'partially updates a todo' do
      # Create a todo first
      create_response = HTTParty.post("#{base_url}/todos",
        body: { title: 'Original', due: '2025-12-31' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      todo_id = JSON.parse(create_response.body)['id']

      # Update just the notes
      response = HTTParty.patch("#{base_url}/todos/#{todo_id}",
        body: { notes: 'Updated notes' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(response.code).to eq(200)

      todo = JSON.parse(response.body)
      expect(todo['notes']).to eq('Updated notes')
      expect(todo['title']).to eq('Original') # Title unchanged
    end
  end

  describe 'PUT /todos/:id' do
    it 'fully updates a todo' do
      # Create a todo first
      create_response = HTTParty.post("#{base_url}/todos",
        body: { title: 'Original', due: '2025-12-31' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      todo_id = JSON.parse(create_response.body)['id']

      # Full update
      response = HTTParty.put("#{base_url}/todos/#{todo_id}",
        body: {
          title: 'Updated Title',
          due: '2026-01-01',
          notes: 'New notes'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(response.code).to eq(200)

      todo = JSON.parse(response.body)
      expect(todo['title']).to eq('Updated Title')
      expect(todo['due']).to eq('2026-01-01')
      expect(todo['notes']).to eq('New notes')
    end
  end

  describe 'DELETE /todos/:id' do
    it 'deletes a todo' do
      # Create a todo first
      create_response = HTTParty.post("#{base_url}/todos",
        body: { title: 'Delete Me', due: '2025-12-31' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      todo_id = JSON.parse(create_response.body)['id']

      # Delete it
      response = HTTParty.delete("#{base_url}/todos/#{todo_id}")

      expect(response.code).to eq(204)

      # Verify it's gone
      get_response = HTTParty.get("#{base_url}/todos/#{todo_id}")
      expect(get_response.code).to eq(404)
    end
  end

  describe 'Custom header' do
    it 'includes Message-For-Tyler header in responses' do
      response = HTTParty.get("#{base_url}/todos")

      expect(response.headers['message-for-tyler']).to eq('Bish bosh bash')
    end
  end

  describe 'Error cases' do
    describe '404 errors' do
      it 'returns 404 for GET /' do
        response = HTTParty.get("#{base_url}/")

        expect(response.code).to eq(404)
        expect(JSON.parse(response.body)['error_message']).to eq('Route does not exist')
      end

      it 'returns 404 when getting non-existent todo' do
        response = HTTParty.get("#{base_url}/todos/99999")

        expect(response.code).to eq(404)
        expect(JSON.parse(response.body)['error_message']).to eq('Todo item not found')
      end

      it 'returns 404 when updating non-existent todo' do
        response = HTTParty.patch("#{base_url}/todos/99999",
          body: { title: 'Updated' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        expect(response.code).to eq(404)
      end

      it 'returns 404 when deleting non-existent todo' do
        response = HTTParty.delete("#{base_url}/todos/99999")

        expect(response.code).to eq(404)
      end
    end

    describe '422 errors' do
      it 'returns 422 when creating todo without title' do
        response = HTTParty.post("#{base_url}/todos",
          body: { due: '2025-12-31' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        expect(response.code).to eq(422)
        expect(JSON.parse(response.body)['error_message']).to include('title')
      end

      it 'returns 422 when creating todo without due date' do
        response = HTTParty.post("#{base_url}/todos",
          body: { title: 'Test' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        expect(response.code).to eq(422)
        expect(JSON.parse(response.body)['error_message']).to include('due')
      end

      it 'returns 422 when creating todo with invalid date format' do
        response = HTTParty.post("#{base_url}/todos",
          body: { title: 'Test', due: 'not-a-date' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        expect(response.code).to eq(422)
        expect(JSON.parse(response.body)['error_message']).to include('ISO 8601')
      end

      it 'returns 422 when PUT without all required fields' do
        # Create a todo first
        create_response = HTTParty.post("#{base_url}/todos",
          body: { title: 'Test', due: '2025-12-31' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        todo_id = JSON.parse(create_response.body)['id']

        # Try PUT with missing fields
        response = HTTParty.put("#{base_url}/todos/#{todo_id}",
          body: { title: 'Updated' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        expect(response.code).to eq(422)
        expect(JSON.parse(response.body)['error_message']).to include('all fields')

        # Clean up
        HTTParty.delete("#{base_url}/todos/#{todo_id}")
      end
    end

    describe '405 errors' do
      it 'returns 405 for PUT /todos (collection)' do
        response = HTTParty.put("#{base_url}/todos")

        expect(response.code).to eq(405)
        expect(JSON.parse(response.body)['error_message']).to include('collection')
      end

      it 'returns 405 for PATCH /todos (collection)' do
        response = HTTParty.patch("#{base_url}/todos")

        expect(response.code).to eq(405)
        expect(JSON.parse(response.body)['error_message']).to include('collection')
      end

      it 'returns 405 for DELETE /todos (collection)' do
        response = HTTParty.delete("#{base_url}/todos")

        expect(response.code).to eq(405)
        expect(JSON.parse(response.body)['error_message']).to include('collection')
      end

      it 'returns 405 for POST /todos/:id' do
        # Create a todo first
        create_response = HTTParty.post("#{base_url}/todos",
          body: { title: 'Test', due: '2025-12-31' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        todo_id = JSON.parse(create_response.body)['id']

        response = HTTParty.post("#{base_url}/todos/#{todo_id}")

        expect(response.code).to eq(405)
        expect(JSON.parse(response.body)['error_message']).to include('POST')

        # Clean up
        HTTParty.delete("#{base_url}/todos/#{todo_id}")
      end
    end
  end
end
