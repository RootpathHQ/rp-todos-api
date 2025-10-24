# Teacher Notes - Todos API

Quick reference for teaching features in this API.

## Basic API Structure

### Endpoints Overview

**Collection Endpoints:**
- `GET /todos` - List all todos (returns id and title only)
- `POST /todos` - Create a new todo

**Individual Todo Endpoints:**
- `GET /todos/:id` - Get a single todo (full details)
- `PATCH /todos/:id` - Partially update a todo
- `PUT /todos/:id` - Fully replace a todo
- `DELETE /todos/:id` - Delete a todo

### Todo Data Model

Each todo has:
- `id` (integer) - Auto-generated, read-only
- `title` (string, required) - The todo text
- `due` (date string, required) - ISO 8601 format: `YYYY-MM-DD`
- `notes` (string, optional) - Additional notes, defaults to empty string
- `created_at` (timestamp) - Auto-generated
- `updated_at` (timestamp) - Auto-updated

### Creating Todos (POST /todos)

**Required fields:** `title`, `due`
**Optional fields:** `notes`

```bash
# Minimal
http POST /todos title="Learn APIs" due="2025-12-31"

# With notes
http POST /todos title="Learn APIs" due="2025-12-31" notes="Start with GET requests"
```

**Returns:** 201 Created with full todo object (including generated id)

### Updating Todos

**PATCH (partial update)** - Send only the fields you want to change:
```bash
http PATCH /todos/1 notes="Updated notes"
http PATCH /todos/1 title="New title" due="2026-01-01"
```

**PUT (full replacement)** - Must send ALL fields:
```bash
http PUT /todos/1 title="Complete title" due="2025-12-31" notes="All fields required"
```

**Returns:** 200 OK with updated todo object

### Deleting Todos

```bash
http DELETE /todos/1
```

**Returns:** 204 No Content (empty response body)

---

## Multiple Format Support (GET only)

The API can return data in three formats:

- **JSON** (default): `/todos` or `/todos.json`
- **XML**: `/todos.xml` or `/todos/:id.xml`
- **Markdown**: `/todos.md` or `/todos/:id.md`

Great for teaching content negotiation and different data formats!

## HTTP Status Codes

The API demonstrates many different status codes:

- **200 OK** - Successful GET requests
- **201 Created** - Successful POST to create a todo
- **204 No Content** - Successful DELETE (no body returned)
- **404 Not Found** - Todo doesn't exist, or invalid route
- **405 Method Not Allowed** - Invalid HTTP method for endpoint
- **409 Conflict** - Duplicate todo (same title + due date)
- **418 I'm a Teapot** - Easter egg (see below!)
- **422 Unprocessable Entity** - Missing required fields or invalid data

## Easter Eggs & Special Features

### 418 I'm a Teapot ☕

Try to create a todo with "teapot" in the title (case-insensitive):

```bash
http POST /todos title="Buy a teapot" due="2025-12-31"
```

Returns:
- 418 status code
- ASCII art teapot in the response
- Custom header: `X-Teapot: Short and stout`
- Link to Wikipedia explaining the joke

### Custom Header

**Every response** includes a custom header:
```
Message-For-Tyler: Bish bosh bash
```

Great for teaching about custom HTTP headers!

### 409 Conflict - Duplicate Prevention

Creating a todo with the same `title` AND `due` date returns 409:

```bash
# First one succeeds (201)
http POST /todos title="Learn APIs" due="2025-12-31"

# Second one conflicts (409)
http POST /todos title="Learn APIs" due="2025-12-31"

# But this succeeds - different due date (201)
http POST /todos title="Learn APIs" due="2025-12-30"
```

## PUT vs PATCH

Great for teaching the difference:

- **PATCH** `/todos/:id` - Partial update (any fields)
- **PUT** `/todos/:id` - Full replacement (all fields required: title, due, notes)

```bash
# PATCH - just update notes
http PATCH /todos/1 notes="New notes"

# PUT - must include all fields
http PUT /todos/1 title="Updated" due="2025-12-31" notes="All fields"
```

## 405 Method Not Allowed

Students can learn which methods work where:

- **Cannot** PUT/PATCH/DELETE the collection:
  ```bash
  http PUT /todos      # Returns 405
  http PATCH /todos    # Returns 405
  http DELETE /todos   # Returns 405
  ```

- **Cannot** POST to a specific todo:
  ```bash
  http POST /todos/1   # Returns 405
  ```

## Data Format Examples

### JSON (default)
```bash
http GET /todos
```

### XML
```bash
http GET /todos.xml
http GET /todos/1.xml
```

### Markdown
```bash
http GET /todos.md        # Returns bulleted list
http GET /todos/1.md      # Returns formatted document
```

## Testing Different Content Types

You can send data as:
- Query string parameters
- Form data
- JSON in request body

All work the same!

```bash
# Query string
http POST "/todos?title=Test&due=2025-12-31"

# JSON body (most common)
http POST /todos title="Test" due="2025-12-31"
```

## Quick Demo Script

```bash
# 1. Show custom header
http GET /todos | grep Message-For-Tyler

# 2. Create a todo (201)
http POST /todos title="Learn HTTP" due="2025-12-31"

# 3. Try duplicate (409)
http POST /todos title="Learn HTTP" due="2025-12-31"

# 4. Easter egg! (418)
http POST /todos title="Buy a teapot" due="2025-12-31"

# 5. Show different formats
http GET /todos.md
http GET /todos.xml

# 6. Show PUT vs PATCH
http PATCH /todos/1 notes="Updated"
http PUT /todos/1 title="Test" due="2025-12-31" notes="Full update"

# 7. Show 405 errors
http DELETE /todos     # Can't delete collection!
http POST /todos/1     # Can't POST to specific todo!
```

## Database Management

Clear all todos:
```bash
rake db:clear
```

Reset and seed with sample data:
```bash
rake db:seed
```
