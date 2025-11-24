import subprocess
import threading
from typing import Dict


class ExecutionResult:
    def __init__(self, stdout: str, stderr: str, exit_code: int, timed_out: bool):
        self.stdout = stdout
        self.stderr = stderr
        self.exit_code = exit_code
        self.timed_out = timed_out

    def to_dict(self) -> Dict[str, any]:
        return {
            "stdout": self.stdout,
            "stderr": self.stderr,
            "exit_code": self.exit_code,
            "timed_out": self.timed_out
        }


def execute_code(code: str, timeout: int = 30) -> ExecutionResult:
    """
    Execute Python code in a subprocess with a timeout.

    Args:
        code: Python code to execute
        timeout: Timeout in seconds (default: 30)

    Returns:
        ExecutionResult with stdout, stderr, exit_code, and timed_out flag
    """
    try:
        # Create subprocess to execute Python code
        process = subprocess.Popen(
            ["python", "-c", code],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Wait for completion with timeout
        try:
            stdout, stderr = process.communicate(timeout=timeout)
            return ExecutionResult(
                stdout=stdout,
                stderr=stderr,
                exit_code=process.returncode,
                timed_out=False
            )
        except subprocess.TimeoutExpired:
            # Kill the process if it times out
            process.kill()
            stdout, stderr = process.communicate()
            return ExecutionResult(
                stdout=stdout,
                stderr=stderr + "\nExecution timed out",
                exit_code=-1,
                timed_out=True
            )

    except Exception as e:
        return ExecutionResult(
            stdout="",
            stderr=f"Error executing code: {str(e)}",
            exit_code=-1,
            timed_out=False
        )
