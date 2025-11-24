# Simple Python Sandbox POC

A minimal REST API for executing Python code in isolated subprocesses.

## Components

- **main.py** - FastAPI REST endpoint (`POST /execute`)
- **executor.py** - Subprocess controller that manages code execution
- **test_requests.http** - Example HTTP requests for testing

## Features

- Process-level isolation using `subprocess.Popen`
- 30-second execution timeout
- JSON response with stdout, stderr, exit_code, and timed_out flag
- Handles errors and timeouts gracefully

## Running the Server

```bash
uv run uvicorn main:app --reload
```

Server will start at http://localhost:8000

## API Usage

### Execute Code

**Endpoint:** `POST /execute`

**Request:**
```json
{
  "code": "print('Hello World')"
}
```

**Response:**
```json
{
  "stdout": "Hello World\n",
  "stderr": "",
  "exit_code": 0,
  "timed_out": false
}
```

## Testing

Use the `test_requests.http` file with an HTTP client or curl:

```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "print(2 + 2)"}'
```

## Test Cases

The `test_requests.http` file includes:
1. Successful execution - simple print statements
2. Error case - division by zero
3. Timeout case - infinite loop (30s timeout)
4. Multiple operations - using stdlib modules
5. Root endpoint check
