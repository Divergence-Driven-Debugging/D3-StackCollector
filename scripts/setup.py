import sys

from setupJava import startJava
from setupJs import startJs
from setupPy import startPy

def main(argv: list[str]):

    if len(argv) < 3:
        print('python setup.py [language] [path/to/source]')
        sys.exit(1)

    language, path = argv[1], argv[2]

    if language.lower() == "py":
        startPy(path)
    elif language.lower() == "java":
        startJava(path)
    elif language.lower() == "js":
        startJs(path)

if __name__ == "__main__":

    # python setup.py [language] [path/to/source]
    main(sys.argv)