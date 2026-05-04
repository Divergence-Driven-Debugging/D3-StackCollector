from subprocess import run

PORT = '5678'

def startPy(path: str):
    print('Run debugpy with', path, 'for port', PORT)
    run(['python3', '-m', 'debugpy', '--listen', PORT, '--wait-for-client', path])