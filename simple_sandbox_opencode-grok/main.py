from fastapi import FastAPI
import subprocess

app = FastAPI()


@app.post("/execute")
def execute(request: dict):
    code = request.get("code")
    if not code:
        return {"error": "No code provided"}
    try:
        result = subprocess.run(
            ["python3", "-c", code], capture_output=True, text=True, timeout=30
        )
        return {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "exit_code": result.returncode,
            "timed_out": False,
        }
    except subprocess.TimeoutExpired:
        return {"stdout": "", "stderr": "", "exit_code": -1, "timed_out": True}
