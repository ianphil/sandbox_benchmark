# Create a Sandbox

## Simple Python Sandbox POC Components

1. REST API endpoint that accepts Python code as a string
2. Controller that spawns a new Python subprocess for each request
3. Each subprocess runs in isolation (essentially a forked Python process)
4. Return the execution result (stdout/stderr) to the caller

## Requirements

- You MUST use `uv`: init, add, run, etc...
- Keep it minimal and straightforward
- Use FastAPI for the REST endpoint
- Use subprocess.Popen to fork and execute the code
- Handle basic error cases (timeout, execution errors)
- No complex isolation (just process-level separation)
- Set a 30-second timeout for code execution
- Return JSON with structure: `{"stdout": "...", "stderr": "...", "exit_code": 0, "timed_out": false}`

## Provide

- The API code with a single endpoint: `POST /execute` that takes `{"code": "..."}`
- The controller/manager that handles spawning and capturing output
- A `.http` file with 2-3 example requests (successful execution, error case, timeout case)
- Start the API server using `uv run` and verify it responds to requests

## Project Structure

- Single file implementation is acceptable
- Or split into `main.py` (API) and `executor.py` (controller) if clearer
