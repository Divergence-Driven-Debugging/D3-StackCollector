import sys
from subprocess import run

def startPy(port: int):
    run(['.env/bin/debugpy-adapter', '--port', port])

def startJava(port: int):
    pass
    
def startJs(port: int):
    run(['node --dns-result-order=ipv4first js-debug/src/dapDebugServer.js', port])


def main(argv: list[str]):
    """
    Script must be executed with `python setup.py [language] [port]`
    """

    language, port = argv[1], argv[2]

    if language.lower() == "py":
        startPy(port)
    elif language.lower() == "java":
        startJava(port)
    elif language.lower() == "js":
        startJs(port)

if __name__ == "__main__":
    main(sys.argv)