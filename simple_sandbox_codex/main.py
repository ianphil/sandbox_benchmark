from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from executor import execute_code


app = FastAPI(title="Simple Python Sandbox")


class ExecuteRequest(BaseModel):
    code: str = Field(..., description="Python code to execute", min_length=1)


def _format_exit_code(value):
    return value if value is not None else -1


@app.post("/execute")
async def execute(request: ExecuteRequest):
    if not request.code.strip():
        raise HTTPException(status_code=400, detail="Code must not be empty")

    result = execute_code(request.code, timeout_seconds=30)
    return {
        "stdout": result.stdout,
        "stderr": result.stderr,
        "exit_code": _format_exit_code(result.exit_code),
        "timed_out": result.timed_out,
    }
