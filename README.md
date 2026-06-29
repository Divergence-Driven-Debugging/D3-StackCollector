# StackCollector

This is a Pharo project which launches projects, collect the execution trace and then returns this trace. 
Note that it only supports launching of Python projects for now.

## Installation

In a Pharo 13 image, launch the following code in a Playground
```smalltalk
Metacello new
	baseline: 'StackCollector';
	repository: 'github://Divergence-Driven-Debugging/D3-StackCollector';
	onConflictUseIncoming;
	load
```

## Setup python environment

The Python trace collector relies on a local Python virtual environment and the debugpy DAP adapter.
From the root directory of your Pharo image, create a virtual environment named `venv` and install debugpy:

```Bash
python3 -m venv venv
source venv/bin/activate
pip install debugpy
```

The trace collector expects the following structure:
```
<image-directory>/
├── venv/
│   ├── bin/
│   │   └── python3
├── Pharo.image
└── pharo-local/
```

## Usage 

Once you've install the requierements, you can use the trace collector by doing in your Pharo Playground:

```smalltalk
result := TraceCollector new
	      collectWithoutAssignmentFor: ProjectLangage 
		  onProject: 'my/project/directory' 
		  withEntryPoint: '/my/project/directory/entrypoint'
```

Where: 
- `ProjectLangage` is a subclass of `SupportedLanguage` corresponding to your project langage (ex: `PythonLanguage`, `JSLanguage`, `JavaLanguage`, ...)
- `'my/project/directory'` is the path to your project directory
- `'/my/project/directory/entrypoint'` is the path to the entry point of your project (ex: a `main.py` file in a python project)

Then you will get an array corresponding to the execution trace in `result` variable.
