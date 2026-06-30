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
TraceCollector >> collectFor: aSupportedLanguage onProject: aProjectPath withEntryPoint: aFilePath [
	"Collect the execution trace of the program located at aProjectPath with entry point at aFilePath using aSupportedLanguage, including assignment operations."

	^ self
		  collectFor: aSupportedLanguage
		  onProject: aProjectPath
		  withEntryPoint: aFilePath
		  using: [ :client |
				  (DAPTraceCollector
					   collectStackFrom: client
					   for: aSupportedLanguage) asArray ]
]

{ #category : 'private' }
TraceCollector >> collectFor: aSupportedLanguage onProject: aProjectPath withEntryPoint: aFilePath using: aBlock [
	"Start the DAP adapter for aSupportedLanguage and create a
	DAP client for the program located at aProjectPath with entry point at aFilePath. 
	Evaluate aBlock, passing the client as argument, and ensure that the connection
	is closed when the operation is finished."

	| clientDAP |
	aSupportedLanguage
		launchAdapterAtPort: self port
		onProject: aProjectPath.

	2 seconds asDuration wait.

	clientDAP := aSupportedLanguage
		             createClientForProject: aProjectPath
		             withEntryPoint: aFilePath
		             atPort: self port.

	1 seconds asDuration wait.

	^ [ aBlock value: clientDAP ] ensure: [ clientDAP closeConnection ]
]

{ #category : 'collect' }
TraceCollector >> collectWithoutAssignmentFor: aSupportedLanguage onProject: aProjectPath withEntryPoint: aFilePath [
	"Collect the execution trace of the program located at aProjectPath with entry point at aFilePath
	using aSupportedLanguage, excluding assignment operations."

	^ self
		  collectFor: aSupportedLanguage
		  onProject: aProjectPath
		  withEntryPoint: aFilePath
		  using: [ :client |
				  (DAPTraceCollector
					   collectStackWithoutAssignmentsFrom: client
					   for: aSupportedLanguage) asArray ]
]

{ #category : 'accessing' }
TraceCollector >> port [
	"Hard coded value for the adapter port"
	^ 5678
]
