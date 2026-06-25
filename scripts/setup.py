from pathlib import Path
import sys, os

from dotenv import load_dotenv
from subprocess import run, Popen, PIPE

from jdtls import JDTLS
from lspclient import LSPClient


def startPy(port: int, project_directory: str):
    print('run', project_directory + '/venv/bin/debugpy-adapter', '--port', port, flush=True)
    run([project_directory + '/venv/bin/debugpy-adapter', '--port', port])

def startJava(port: int, project_directory: str):
    """Starts the java adapter on `port` and the java LSP"""

    java_debug_jar = Path(os.getenv("JAVA_DEBUG"))
    jdtls_dir = Path(os.getenv("JDTLS"))

    print('Popen', str(jdtls_dir / "bin" / "jdtls"), flush=True)
    process = Popen(
        [str(jdtls_dir / "bin" / "jdtls")],
        cwd=str(jdtls_dir),
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    client = LSPClient(process)
    jdtls = JDTLS(client, [str(java_debug_jar)])

    print("\nLSP Initialize", flush=True)
    jdtls.initialize(project_directory)

    print("\nLSP startDebugSession", flush=True)
    adapter_port = jdtls.execute_command("vscode.java.startDebugSession")

    # Forward DAP traffic from the requested port to the Java adapter port.
    print(f'\nForward DAP traffic from {port} to {adapter_port}', flush=True)
    run([
        "socat",
        f"TCP-LISTEN:{port},reuseaddr",
        f"TCP:127.0.0.1:{adapter_port}"
    ])
    
def startJs(port: int):
    dapDebugServer = "/Users/flavienvolant/Documents/sindarin-dap/js/js-debug/src/dapDebugServer.js"
    print('run', 'node', '--dns-result-order=ipv4first', dapDebugServer, port, flush=True)
    run(['node', '--dns-result-order=ipv4first', dapDebugServer, port])


def main(argv: list[str]):
    """Script must be executed with `python setup.py [language] [port] [project_directory]`"""

    language, port, project_directory = argv[1], argv[2], argv[3]

    if language.lower() == "py":
        startPy(port, project_directory)
    elif language.lower() == "java":
        startJava(port, project_directory)
    elif language.lower() == "js":
        startJs(port)


if __name__ == "__main__":
    main(sys.argv)
