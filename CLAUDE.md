# To-Dos API Teaching Project

Simple Sinatra REST API for teaching HTTP concepts: methods, response codes, headers, and JSON.

## Running the App

Run the server in a separate terminal window:

```bash
bundle
rake db:migrate

# With hot-reloading (recommended for development)
RACK_ENV=development rerun --pattern '{**/*.rb,**/*.ru,Gemfile,Gemfile.lock,Rakefile}' ruby app.rb

# Or without hot-reloading
ruby app.rb
```

Runs on `http://localhost:4567` by default.

Hot-reloading automatically restarts the server when code changes are made.

## Making Requests

Use HTTPie (cleaner output than curl):

```bash
# Install if needed
brew install httpie

# Example requests
http GET http://localhost:4567/todos
http POST http://localhost:4567/todos title="Learn APIs" due="2025-12-31"
http GET http://localhost:4567/todos/1
http PATCH http://localhost:4567/todos/1 notes="Making progress"
http DELETE http://localhost:4567/todos/1
```

## Development Principles

**Keep it minimal and simple.** Always choose the simplest solution that achieves the goal. This is a teaching tool, not a production app.

## Testing Workflow

**After completing any task, always run RuboCop and then tests to ensure nothing is broken.**

The dev server must be running in a separate terminal window for tests to work. If you get a connection error:
- DO NOT start the dev server yourself
- Ask the user to run the dev server command in another terminal window:
  ```bash
  RACK_ENV=development rerun --pattern '{**/*.rb,**/*.ru,Gemfile,Gemfile.lock,Rakefile}' ruby app.rb
  ```

Then run RuboCop to check for code quality issues:
```bash
bundle exec rubocop
```

If RuboCop finds issues, auto-fix them if possible:
```bash
bundle exec rubocop -A
```

Finally, run the tests:
```bash
bundle exec rspec
```

## API Endpoints

- `GET /todos` - List all todos
- `POST /todos` - Create todo (requires: title, due; optional: notes)
- `GET /todos/:id` - Get single todo
- `PATCH /todos/:id` - Update todo (any fields)
- `PUT /todos/:id` - Full update (all fields required)
- `DELETE /todos/:id` - Delete todo

## Testing

```bash
# Run tests (requires server running in another terminal)
rake            # or
rake spec       # or
bundle exec rspec
```

## Database Management

```bash
# Reset/clear all todos
ruby scripts/reset_db.rb
```
