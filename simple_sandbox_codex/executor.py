import subprocess
import sys
from dataclasses import dataclass
from typing import Optional


@dataclass
class ExecutionResult:
    stdout: str
    stderr: str
    exit_code: Optional[int]
    timed_out: bool


def execute_code(code: str, timeout_seconds: int = 30) -> ExecutionResult:
    """Run the supplied Python code in a new interpreter process."""
    process = subprocess.Popen(
        [sys.executable, "-c", code],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    try:
        stdout, stderr = process.communicate(timeout=timeout_seconds)
        timed_out = False
    except subprocess.TimeoutExpired:
        process.kill()
        stdout, stderr = process.communicate()
        timed_out = True

    return ExecutionResult(
        stdout=stdout,
        stderr=stderr,
        exit_code=process.returncode,
        timed_out=timed_out,
    )
