"
I represent the JS language within the trace collection framework.

I implement the language-specific services required by SupportedLanguage
by:
- launching a js debug adapter,
- creating a DAP client configured with the JS backend,
- preparing the execution of a JS project for trace collection.

This class is used by TraceCollector to obtain
execution traces from js programs.
"
Class {
	#name : 'JSLanguage',
	#superclass : 'SupportedLanguage',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
JSLanguage class >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	aNode type = 'assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	aNode type = 'variable_declarator' ifTrue: [
		^ aNode nodeChildByFieldName: 'name' ].

	aNode type = 'augmented_assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	^ nil
]

{ #category : 'actions' }
JSLanguage class >> createClientFor: aPath atPort: aNumber [
	"Create a DAP client configured to debug the source located at aPath
	through the adapter listening on aNumber."

	^ DAPClientBuilder newSindarinClient
		  port: aNumber;
		  adapterID: 'node';
		  arguments: {
				  ('program' -> aPath).
				  ('request' -> 'launch').
				  ('justMyCode' -> false).
				  ('stopOnEntry' -> true).
				  ('type' -> 'pwa-node').
				  ('skipFiles' -> { '<node_internals>/**' }) } asDictionary;
		  backend: DAPBackendJavaScript new;
		  startDebuggingRequest: true;
		  startClientSession
]

{ #category : 'testing' }
JSLanguage class >> isAssignmentNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'assignment_expression' 'augmented_assignment_expression'
	     'variable_declarator' ) includes: aNode type
]

{ #category : 'testing' }
JSLanguage class >> isTerminalTargetNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'identifier' 'member_expression' 'subscript_expression'
	     'shorthand_property_identifier_pattern' ) includes: aNode type
]

{ #category : 'accessing' }
JSLanguage class >> languageToParse [
	"Return the target language, a TSLanguage"

	^ TSLanguage typescript
]

{ #category : 'actions' }
JSLanguage class >> launchAdapterAtPort: aNumber [
	"Start the language-specific DAP adapter configured to accept connections on port aNumber"

	^ AdapterLauncher launchJSAdapterAtPort: aNumber
]

{ #category : 'asserting' }
JSLanguage class >> shouldSkipForPath: aPath [
	"Answer true if aPath should be ignored when collecting traces."

	^ false
]
