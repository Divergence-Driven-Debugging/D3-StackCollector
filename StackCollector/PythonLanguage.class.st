"
I represent the Python language within the trace collection framework.

I implement the language-specific services required by SupportedLanguage
by:
- launching a Python debug adapter,
- creating a DAP client configured with the Python backend,
- preparing the execution of a Python script for trace collection.

Instances of this class are typically used by TraceCollector to obtain
execution traces from Python programs.
"
Class {
	#name : 'PythonLanguage',
	#superclass : 'SupportedLanguage',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
PythonLanguage class >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	^ aNode nodeChildByFieldName: 'left'
]

{ #category : 'actions' }
PythonLanguage class >> createClientFor: aPath atPort: aNumber [
	"Create a DAP client configured to debug the source located at aPath
	through the adapter listening on aNumber."

	^ DAPClientBuilder newSindarinClient
		  port: aNumber;
		  adapterID: 'python';
		  functionBreakpoint: 'main';
		  arguments: {
				  ('program' -> aPath).
				  ('justMyCode' -> false) } asDictionary;
		  backend: DAPBackendPython new;
		  startClientSession
]

{ #category : 'testing' }
PythonLanguage class >> isAssignmentNode: aNode [
	"Answer wether aNode an assignment for the target language."

	^ #( 'assignment' 'augmented_assignment' ) includes: aNode type
]

{ #category : 'testing' }
PythonLanguage class >> isTerminalTargetNode: aNode [

	^ #( 'identifier' 'attribute' 'subscript' ) includes: aNode type
]

{ #category : 'accessing' }
PythonLanguage class >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage python
]

{ #category : 'actions' }
PythonLanguage class >> launchAdapterAtPort: aNumber [
	"Start the python adapter configured to accept connections on port aNumber."

	AdapterLauncher launchPythonAdapterAtPort: aNumber
]

{ #category : 'asserting' }
PythonLanguage class >> shouldSkipForPath: aPath [
	"Answer true if aPath should be ignored when collecting traces."

	^ aPath includesSubstring: 'runpy.py'
]
