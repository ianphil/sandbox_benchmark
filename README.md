# AI Coding Agent Benchmark

A benchmark suite for comparing AI coding agents on a standardized task: building a Python code execution sandbox API.

## What This Is

This repo provides a consistent framework for running multiple AI coding agents against the same prompt and evaluating their outputs using LLM-as-a-judge. Each agent works in its own isolated directory, producing implementations that can be objectively compared.

## Supported Agents

| Agent | Model | Directory |
|-------|-------|-----------|
| GitHub Copilot | gpt-5.1-codex | `simple_sandbox_copilot-codex/` |
| Claude | sonnet | `simple_sandbox_claude/` |
| Codex | gpt-5.1-codex | `simple_sandbox_codex/` |
| Gemini | (default) | `simple_sandbox_gemini/` |
| OpenCode | grok-code | `simple_sandbox_opencode-grok/` |

## Quick Start

### 1. Clean Up Previous Runs

```bash
./scripts/cleanup_agents.sh
```

Removes all generated files from agent directories while preserving `.gitkeep` files.

### 2. Run the Benchmark

```bash
./scripts/run_benchmark.sh
```

Select an option:
- **1-5**: Run a single agent
- **6**: Run all agents sequentially
- **7**: Run all agents in parallel

Logs are saved to `benchmark_logs_<timestamp>/`.

### 3. Evaluate Results

```bash
./scripts/run_evaluation.sh
```

Uses Claude as an LLM judge to score each implementation against the evaluation criteria.

Select an option:
- **1**: Evaluate a specific agent
- **2**: Evaluate all sequentially
- **3**: Evaluate all in parallel

Evaluations are saved to `evaluations_<timestamp>/`.

## Configuration

Override default models via environment variables:

```bash
COPILOT_MODEL=claude-sonnet-4 CLAUDE_MODEL=opus ./scripts/run_benchmark.sh
```

## Files

| File | Purpose |
|------|---------|
| `benchmark-prompt.md` | The task given to each AI agent |
| `evaluation-template.md` | Scoring rubric (100 points + 15 bonus) |
| `evaluation-prompt.md` | Instructions for LLM judge |
| `scripts/run_benchmark.sh` | Runs AI agents |
| `scripts/run_evaluation.sh` | Runs LLM-as-a-judge evaluation |
| `scripts/cleanup_agents.sh` | Cleans agent directories |

## The Task

Each agent is asked to build a minimal Python sandbox API:

- FastAPI REST endpoint (`POST /execute`)
- Subprocess-based code execution with 30-second timeout
- JSON response: `{"stdout": "...", "stderr": "...", "exit_code": 0, "timed_out": false}`
- Must use `uv` for project setup
- Include `.http` file with test cases

See `benchmark-prompt.md` for full requirements.

## Evaluation Criteria

Implementations are scored on:

- **Setup & Initialization** (20 pts): uv usage, FastAPI, dependencies
- **Core Functionality** (40 pts): endpoint, subprocess, timeout, response format
- **Testing & Verification** (20 pts): .http file, test cases, verification
- **Code Quality** (20 pts): isolation, error handling, readability
- **Bonus** (+15 pts): unit tests, modularity, one-shot completion

See `evaluation-template.md` for the full rubric.
