# Evaluation Instructions

You are evaluating an AI coding agent's implementation of a Python sandbox API. Your task is to objectively score the implementation against the criteria below.

## What You're Evaluating

The agent was given the prompt from `benchmark-prompt.md` to create a minimal Python code execution sandbox. Review the agent's implementation and score it according to the evaluation template.

## How to Conduct the Evaluation

1. **Locate the implementation directory** - Find the agent's output folder (e.g., `simple_sandbox_claude/`, `simple_sandbox_copilot/`)

2. **Review the code** - Read through the implementation files to understand the structure

3. **Test functionality** - Run the implementation and test the API with the provided .http file (if present)

4. **Score each criterion** - Use the checklist below, marking items complete and assigning points

5. **Calculate total score** - Sum all points including any bonuses earned

6. **Provide brief notes** - Document key observations for each major category

## Evaluation Checklist

### Setup & Initialization (20 points)
- [ ] Uses `uv init` to initialize project (5 pts)
  - Check for `pyproject.toml` and proper uv project structure
- [ ] Can be run with `uv run` command (5 pts)
  - Test: `uv run main.py` or `uv run uvicorn main:app`
- [ ] Uses FastAPI as specified (5 pts)
  - Verify FastAPI is imported and used
- [ ] All dependencies properly declared (5 pts)
  - Check `pyproject.toml` has fastapi, uvicorn, etc.

**Notes:**

### Core Functionality (40 points)
- [ ] POST /execute endpoint implemented correctly (10 pts)
  - Endpoint exists, accepts POST requests with JSON body
  - Request body structure: `{"code": "..."}`
- [ ] Uses subprocess.Popen for execution (10 pts)
  - Verify subprocess.Popen is used (not os.system, eval, exec, etc.)
- [ ] Returns correct JSON structure (10 pts)
  - Response must include: `stdout`, `stderr`, `exit_code`, `timed_out`
  - Test by making actual requests
- [ ] Implements 30-second timeout (10 pts)
  - Check timeout is set in subprocess call or thread management
  - Test with `time.sleep(35)` to verify timeout works

**Notes:**

### Testing & Verification (20 points)
- [ ] Includes .http file with test requests (5 pts)
  - File exists with proper format
- [ ] .http file has 3 test cases: success, error, timeout (10 pts)
  - Success case: Simple print or calculation
  - Error case: Code that raises exception
  - Timeout case: Code with long sleep/infinite loop
- [ ] Agent ran the API and verified it works (5 pts)
  - Check logs or output showing agent tested the API
  - Evidence of successful test execution

**Notes:**

### Code Quality (20 points)
- [ ] Process-level isolation properly implemented (10 pts)
  - Each request spawns separate subprocess
  - No shared state between requests
  - Test with concurrent requests if possible
- [ ] Error handling for execution errors (5 pts)
  - Handles subprocess exceptions gracefully
  - Returns appropriate error messages
- [ ] Clean, readable code structure (5 pts)
  - Clear variable names
  - Logical organization
  - Minimal code duplication

**Notes:**

### Bonus Points
- [ ] Includes unit tests (+5 pts)
  - Actual test files present (test_*.py or similar)
  - Tests are runnable and pass
- [ ] Modular structure (separate controller) (+5 pts)
  - Logic separated into multiple files/modules
  - Clear separation of concerns (API vs execution logic)
- [ ] Completed in single attempt without errors (+5 pts)
  - Review agent logs/transcript
  - No major revisions or error fixes required

**Notes:**

## Scoring Summary

| Category | Points Earned | Points Possible |
|----------|---------------|-----------------|
| Setup & Initialization | ___ | 20 |
| Core Functionality | ___ | 40 |
| Testing & Verification | ___ | 20 |
| Code Quality | ___ | 20 |
| **Subtotal** | ___ | **100** |
| Bonus Points | ___ | 15 |
| **Final Score** | ___ | **115** |

## Final Assessment

**Score: ___/100 (___/115 with bonuses)**

**Rating:**
- [ ] 90-100+: Excellent - Production ready
- [ ] 75-89: Good - Minor improvements needed
- [ ] 60-74: Acceptable - Some issues to address
- [ ] Below 60: Needs significant rework

**Summary:**

[Provide 2-3 sentences summarizing the implementation's strengths and weaknesses]

**Key Strengths:**
-
-

**Areas for Improvement:**
-
-

**Would you deploy this code?** [ ] Yes [ ] With changes [ ] No

## Testing Commands

Use these commands during evaluation:

```bash
# Navigate to implementation directory
cd simple_sandbox_[agent_name]/

# Check project structure
ls -la

# Review pyproject.toml
cat pyproject.toml

# Install dependencies (if needed)
uv sync

# Run the API
uv run uvicorn main:app --host 0.0.0.0 --port 8000

# In another terminal, test the endpoint
# If .http file exists, use VS Code REST Client extension
# Or use curl:
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "print(\"Hello, World!\")"}'

# Test timeout (should take ~30 seconds)
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "import time; time.sleep(35)"}'

# Test error handling
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "raise ValueError(\"Test error\")"}'
```
