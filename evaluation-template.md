# Evaluation Criteria

## Setup & Initialization (20 points)
- [ ] Uses `uv init` to initialize project (5 pts)
- [ ] Can be run with `uv run` command (5 pts)
- [ ] Uses FastAPI as specified (5 pts)
- [ ] All dependencies properly declared (5 pts)

## Core Functionality (40 points)
- [ ] POST /execute endpoint implemented correctly (10 pts)
- [ ] Uses subprocess.Popen for execution (10 pts)
- [ ] Returns correct JSON structure: `{"stdout": "...", "stderr": "...", "exit_code": 0, "timed_out": false}` (10 pts)
- [ ] Implements 30-second timeout (10 pts)

## Testing & Verification (20 points)
- [ ] Includes .http file with test requests (5 pts)
- [ ] .http file has 3 test cases: success, error, timeout (10 pts)
- [ ] Agent ran the API and verified it works (5 pts)

## Code Quality (20 points)
- [ ] Process-level isolation properly implemented (10 pts)
- [ ] Error handling for execution errors (5 pts)
- [ ] Clean, readable code structure (5 pts)

## Bonus Points
- [ ] Includes unit tests (+5 pts)
- [ ] Modular structure (separate controller) (+5 pts)
- [ ] Completed in single attempt without errors (+5 pts)

**Total: 100 points (115 with bonuses)**

## Scoring Guide
- 90-100+: Excellent - Production ready
- 75-89: Good - Minor improvements needed
- 60-74: Acceptable - Some issues to address
- Below 60: Needs significant rework
