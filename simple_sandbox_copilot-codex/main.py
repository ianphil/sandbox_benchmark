from dataclasses import asdict

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from executor import ExecutionResult, run_code_in_subprocess

app = FastAPI(title="Simple Python Sandbox", version="0.1.0")


class ExecuteRequest(BaseModel):
    code: str


class ExecuteResponse(BaseModel):
    stdout: str
    stderr: str
    exit_code: int
    timed_out: bool


@app.post("/execute", response_model=ExecuteResponse)
async def execute(payload: ExecuteRequest) -> ExecuteResponse:
    if not payload.code.strip():
        raise HTTPException(status_code=400, detail="Code must not be empty.")

    try:
        result: ExecutionResult = run_code_in_subprocess(payload.code)
    except Exception as exc:  # pragma: no cover - defensive
        raise HTTPException(status_code=500, detail=f"Executor error: {exc}") from exc

    return ExecuteResponse(**asdict(result))
