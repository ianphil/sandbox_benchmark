from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from executor import execute_code

app = FastAPI(title="Simple Python Sandbox")


class CodeRequest(BaseModel):
    code: str


@app.post("/execute")
async def execute_endpoint(request: CodeRequest):
    """
    Execute Python code in an isolated subprocess.

    Args:
        request: CodeRequest containing the Python code to execute

    Returns:
        JSON with stdout, stderr, exit_code, and timed_out flag
    """
    if not request.code:
        raise HTTPException(status_code=400, detail="Code cannot be empty")

    result = execute_code(request.code, timeout=30)
    return result.to_dict()


@app.get("/")
async def root():
    return {"message": "Simple Python Sandbox API - POST code to /execute"}
