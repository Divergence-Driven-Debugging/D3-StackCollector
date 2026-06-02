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

Example for a python adapter listening to port 5678:
```smalltalk
client := DAPClientBuilder newSindarinClient
	          port: 5678;
	          adapterID: 'python';
	          functionBreakpoint: 'main';
	          attachArguments: {
			          ('connect' -> {
					           ('host' -> 'localhost').
					           ('port' -> 5678) } asDictionary).
			          ('justMyCode' -> false) } asDictionary;
	          backend: DAPBackendPython new;
	          startClientSession.

res := StackCollector collectStackFrom: client.
```
