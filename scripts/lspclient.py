import json
import queue
import threading
from subprocess import Popen


class LSPClient:
    def __init__(self, process: Popen):
        self.process = process

        self._next_id = 1
        self._running = True

        self._response_queues: dict[int, queue.Queue] = {}

        self._reader_thread = threading.Thread(
            target=self._reader_loop,
            daemon=True
        )
        self._reader_thread.start()

    def _read_exact(self, size: int) -> bytes | None:
        """Read exactly size bytes from stdout"""

        data = b""

        while len(data) < size:
            chunk = self.process.stdout.read(size - len(data))

            if not chunk:
                return None

            data += chunk

        return data

    def _reader_loop(self):
        """Read and dispatch incoming LSP messages from self.process stdout"""

        while self._running:
            headers = {}

            # Read message header
            while True:
                line = self.process.stdout.readline()

                if not line:
                    self._running = False
                    return

                if line in (b"\r\n", b"\n"):
                    break

                key, value = line.decode().split(":", 1)
                headers[key.strip().lower()] = value.strip()

            content_length = int(headers["content-length"])

            # Read message body
            body = self._read_exact(content_length)

            if body is None:
                self._running = False
                return

            message = json.loads(body.decode())

            # Handle request responses
            if "id" in message and (
                "result" in message or "error" in message
            ):
                response_queue = self._response_queues.get(message["id"])

                if response_queue:
                    response_queue.put(message)

    def _send(self, payload: dict):
        """Send a JSON-RPC message"""
        body = json.dumps(payload).encode()

        header = (
            f"Content-Length: {len(body)}\r\n\r\n"
        ).encode()

        self.process.stdin.write(header)
        self.process.stdin.write(body)
        self.process.stdin.flush()
    
    def request(
        self,
        method: str,
        params: dict,
        timeout: float = 30.0
    ):
        """Send a request and wait for the response"""
        request_id = self._next_id
        self._next_id += 1

        response_queue = queue.Queue(maxsize=1)
        self._response_queues[request_id] = response_queue

        self._send({
            "jsonrpc": "2.0",
            "id": request_id,
            "method": method,
            "params": params,
        })

        try:
            response = response_queue.get(timeout=timeout)

            if "error" in response:
                raise RuntimeError(response["error"])

            return response["result"]

        finally:
            self._response_queues.pop(request_id, None)

    def notify(
        self,
        method: str,
        params: dict
    ):
        """Send a notification"""
        self._send({
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
        })

    def close(self):
        self._running = False