# Simple Python Sandbox

A minimal FastAPI service that executes arbitrary Python code in an isolated subprocess with a 30-second timeout.

## Setup

```bash
uv sync
```

## Run the API

```bash
uv run fastapi dev main:app --host 127.0.0.1 --port 8000
```

Send a `POST /execute` request with JSON `{ "code": "print(42)" }` and receive `{ "stdout", "stderr", "exit_code", "timed_out" }` in response.
Use `requests.http` for ready-made success, error, and timeout examples.
