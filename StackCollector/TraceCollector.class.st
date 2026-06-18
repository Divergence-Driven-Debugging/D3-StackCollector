"
I am responsible for:
- launching a Debug Adapter Protocol (DAP) adapter for a supported language,
- creating and connecting a DAP client to the adapter,
- collecting execution traces produced during the program execution.

I coordinate the complete trace collection workflow: adapter startup,
client connection, trace retrieval, and connection shutdown.

How to use me:

```smalltalk
res := TraceCollector new
	collectFor: PythonLanguage new
	path: 'path/to/script.py'.
```

The result is an array of execution traces gathered from the executed program.
see: https://github.com/RemiDufloer/Trace-Model-Design
"
Class {
	#name : 'TraceCollector',
	#superclass : 'Object',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'collect' }
TraceCollector >> collectFor: aSupportedLanguage path: aPath [
	"Collect the execution trace of the program located at
	aPath using aSupportedLanguage, including assignment operations."

	^ self
		  collectFor: aSupportedLanguage
		  path: aPath
		  using: [ :client |
		  (DAPTraceCollector collectStackFrom: client) asArray ]
]

{ #category : 'private' }
TraceCollector >> collectFor: aSupportedLanguage path: aPath using: aBlock [
	"Start the DAP adapter for aSupportedLanguage and create a
	DAP client for the program located at aPath. Evaluate aBlock,
	passing the client as argument, and ensure that the connection
	is closed when the operation is finished."

	| clientDAP |
	aSupportedLanguage launchAdapterAtPort: self port.

	1 seconds asDuration wait.

	clientDAP := aSupportedLanguage
		             createClientFor: aPath
		             atPort: self port.

	1 seconds asDuration wait.

	^ [ aBlock value: clientDAP ] ensure: [ clientDAP closeConnection ]
]

{ #category : 'collect' }
TraceCollector >> collectWithoutAssignmentFor: aSupportedLanguage path: aPath [
	"Collect the execution trace of the program located at
	aPath using aSupportedLanguage, excluding assignment operations."

	^ self collectFor: aSupportedLanguage path: aPath using: [ :client |
		  (DAPTraceCollector collectStackWithoutAssignmentsFrom: client)
			  asArray ]
]

{ #category : 'accessing' }
TraceCollector >> port [
	"Hard coded value for the adapter port"
	^ 5678
]
