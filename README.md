# StackCollector

This is a Pharo project which launches projects, collect the execution trace and then returns this trace. 
Note that it only supports launching of Python projects for now.

## How to

Pharo 13
```smalltalk
Metacello new
	baseline: 'StackCollector';
	repository: 'github://Divergence-Driven-Debugging/D3-StackCollector';
	onConflictUseIncoming;
	load
```

Example for python:
```smalltalk
res := TraceCollector new
	       collectFor: PythonLanguage new
	       path: '/path/to/file/to/collect/execution.py'.
```


## Setup python environment

The Python trace collector relies on a local Python virtual environment and the debugpy DAP adapter.
From the root directory of your Pharo image, create a virtual environment named .env and install debugpy:

```Bash
python3 -m venv .env
source .env/bin/activate
pip install debugpy
```

The trace collector expects the following structure:
```
<image-directory>/
├── .env/
│   ├── bin/
│   │   └── python3
├── Pharo.image
└── pharo-local/
```
