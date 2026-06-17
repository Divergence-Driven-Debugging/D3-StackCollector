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
    aPath using aSupportedLanguage.

    This method starts the corresponding DAP adapter, waits for it to
    become available, creates a DAP client, waits for the connection
    to be established, collects the execution trace, and finally
    closes the client connection."

	| clientDAP res |
	aSupportedLanguage launchAdapterAtPort: self port.

	1 seconds asDuration wait.

	clientDAP := aSupportedLanguage
		             createClientFor: aPath
		             atPort: self port.

	1 seconds asDuration wait.

	res := (DAPTraceCollector collectStackFrom: clientDAP) asArray.
	clientDAP closeConnection.
	^ res
]

{ #category : 'collect' }
TraceCollector >> collectWithoutAssignmentFor: aSupportedLanguage path: aPath [
	"Collect the execution trace of the program located at
    aPath using aSupportedLanguage.

    This method starts the corresponding DAP adapter, waits for it to
    become available, creates a DAP client, waits for the connection
    to be established, collects the execution trace, and finally
    closes the client connection."

	| clientDAP res |
	aSupportedLanguage launchAdapterAtPort: self port.

	1 seconds asDuration wait.

	clientDAP := aSupportedLanguage
		             createClientFor: aPath
		             atPort: self port.

	1 seconds asDuration wait.

	res := (DAPTraceCollector collectStackWithoutAssignmentsFrom:
		        clientDAP) asArray.
	clientDAP closeConnection.
	^ res
]

{ #category : 'accessing' }
TraceCollector >> port [
	"Hard coded value for the adapter port"
	^ 5678
]
