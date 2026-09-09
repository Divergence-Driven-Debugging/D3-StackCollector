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
PythonLanguage class >> createClientForProject: aProjectPath withEntryPoint: aFilePath atPort: aNumber [


	| builder arguments |
	arguments := Dictionary new
		             at: 'program' put: aFilePath;
		             at: 'justMyCode' put: self justMyCode;
		             yourself.

	builder := DAPClientBuilder newSindarinClient
		           port: aNumber;
		           adapterID: 'python';
		           backend: DAPBackendPython new;
		           yourself.

	(self entryFunctionNameFor: aFilePath)
		ifNotNil: [ :functionName | builder functionBreakpoint: functionName ]
		ifNil: [ arguments at: 'stopOnEntry' put: true ].

	builder arguments: arguments.

	^ builder startClientSession
]

{ #category : 'accessing' }
PythonLanguage class >> entryFunctionNameFor: aFilePath [

	| reference |
	reference := aFilePath asFileReference.
	reference exists ifFalse: [ ^ nil ].

	^ (reference contents lines anySatisfy: [ :line |
			   (line beginsWith: 'def main(') or: [
				   line beginsWith: 'async def main(' ] ]) ifTrue: [ 'main' ]
]

{ #category : 'testing' }
PythonLanguage class >> isAssignmentNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'assignment' 'augmented_assignment' ) includes: aNode type
]

{ #category : 'testing' }
PythonLanguage class >> isTerminalTargetNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'identifier' 'attribute' 'subscript' ) includes: aNode type
]

{ #category : 'accessing' }
PythonLanguage class >> justMyCode [


	^ false
]

{ #category : 'accessing' }
PythonLanguage class >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage python
]

{ #category : 'actions' }
PythonLanguage class >> launchAdapterAtPort: aNumber onProject: aProjectPath [
	"Start the python adapter configured to accept connections at port aNumber and on project at aProjectPath."

	AdapterLauncher launchPythonAdapterAtPort: aNumber onProject: aProjectPath 
]

{ #category : 'asserting' }
PythonLanguage class >> shouldSkipForPath: aPath [
	"Answer true if aPath should be ignored when collecting traces."

	^ aPath includesSubstring: 'runpy.py'
]

{ #category : 'asserting' }
PythonLanguage class >> shouldSkipForPath: aPath inProject: aProjectPath [

	| path project |
	path := aPath asString.

	"runpy is the module launcher of the adapter, never interesting"
	(path includesSubstring: 'runpy.py') ifTrue: [ ^ true ].

	self traceScope = #everything ifTrue: [ ^ false ].

	"the files of the project itself are always traced"
	project := aProjectPath asString.
	((path beginsWith: project) and: [
		 (path includesSubstring: 'site-packages') not ]) ifTrue: [ ^ false ].

	self traceScope = #project ifTrue: [ ^ true ].

	"#projectAndLibraries: third party packages yes, standard library no"
	^ (path includesSubstring: 'site-packages') not and: [
		  (path includesSubstring: 'dist-packages') not ]
]

{ #category : 'accessing' }
PythonLanguage class >> traceScope [

	^ #projectAndLibraries
]
