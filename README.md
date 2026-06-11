# StackCollector

This is a Pharo project which launches projects, collect the execution trace and then returns this trace. 
Note that it only supports launching of Python projects for now.

## How to

Pharo 13
```smalltalk
Metacello new
	baseline: 'StackCollector';
	repository: 'github://Divergence-Driven-Debugging/D3-StackCollector';
	load
```

Example for python:
```smalltalk
res := TraceCollector new
	       collectFor: PythonLanguage new
	       path: '/path/to/file/to/collect/execution.py'.
```
