"
I represent a programming language supported by the trace collection framework.

My subclasses are responsible for providing the language-specific
configuration required to communicate through the Debug Adapter Protocol (DAP).

Subclasses must implement:
- `launchAdapterAtPort:` to start the appropriate DAP adapter,
- `createClientFor:atPort:` to create and configure a DAP client for a given source file.
"
Class {
	#name : 'SupportedLanguage',
	#superclass : 'Object',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
SupportedLanguage class >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	^ self subclassResponsibility
]

{ #category : 'actions' }
SupportedLanguage class >> createClientForProject: aProjectPath withEntryPoint: aFilePath atPort: aNumber [
	"Create a DAP client configured to debug the source located at aProjectPath with entry point at aFilePath
	through the adapter listening on aNumber.

	Subclasses must provide a language-specific implementation."

	^ self subclassResponsibility
]

{ #category : 'testing' }
SupportedLanguage class >> isAssignmentNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ self subclassResponsibility
]

{ #category : 'testing' }
SupportedLanguage class >> isTerminalTargetNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
SupportedLanguage class >> languageToParse [
	"Return the target language, a TSLanguage"

	^ self subclassResponsibility
]

{ #category : 'actions' }
SupportedLanguage class >> launchAdapterAtPort: aNumber onProject: aProjectPath [
	"Start the language-specific DAP adapter configured to accept connections at port aNumber and on project at aProjectPath.

	Subclasses must implement the adapter startup procedure."

	^ self subclassResponsibility
]

{ #category : 'asserting' }
SupportedLanguage class >> shouldSkipForPath: aPath [
	"Answer true if aPath should be ignored when collecting traces."

	^ self subclassResponsibility
]
