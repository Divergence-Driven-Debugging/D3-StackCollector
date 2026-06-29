"
I represent the Java language within the trace collection framework.

I implement the language-specific services required by SupportedLanguage
by:
- launching a java debug adapter,
- creating a DAP client configured with the Java backend,
- preparing the execution of a Java project for trace collection.

This class is used by TraceCollector to obtain
execution traces from java programs.
"
Class {
	#name : 'JavaLanguage',
	#superclass : 'SupportedLanguage',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
JavaLanguage class >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	aNode type = 'assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	aNode type = 'variable_declarator' ifTrue: [
		^ aNode nodeChildByFieldName: 'name' ].

	^ nil
]

{ #category : 'actions' }
JavaLanguage class >> createClientFor: aPath atPort: aNumber [
	"Create a DAP client configured to debug the source located at aPath
	through the adapter listening on aNumber."

	^ DAPClientBuilder newSindarinClient
		  port: aNumber;
		  adapterID: 'java';
		  functionBreakpoint: 'example.Main#main';
		  arguments: {
				  ('console' -> 'internalConsole').
				  ('mainClass' -> 'example.Main').
				  ('classPaths'
				   ->
					   { '/Users/flavienvolant/Documents/sindarin-dap/java/target/classes' }).
				  ('sourcePaths'
				   ->
					   { '/Users/flavienvolant/Documents/sindarin-dap/java/src/main/java' }).
				  ('justMyCode' -> true) } asDictionary;
		  backend: DAPBackendJava new;
		  startClientSession
]

{ #category : 'testing' }
JavaLanguage class >> isAssignmentNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'assignment_expression' 'variable_declarator' ) includes:
		  aNode type
]

{ #category : 'testing' }
JavaLanguage class >> isTerminalTargetNode: aNode [
	"Answer whether or not aNode an assignment for the target language."

	^ #( 'identifier' 'field_access' 'array_access' ) includes:
		  aNode type
]

{ #category : 'accessing' }
JavaLanguage class >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage java
]

{ #category : 'actions' }
JavaLanguage class >> launchAdapterAtPort: aNumber onProject: aProjectPath [
	"Start the java adapter configured to accept connections at port aNumber and on project at aProjectPath"

	AdapterLauncher launchJavaAdapterAtPort: aNumber onProject: aProjectPath 
]

{ #category : 'asserting' }
JavaLanguage class >> shouldSkipForPath: aPath [
	"Answer true if aPath should be ignored when collecting traces."

	^ aPath includesSubstring: 'JavaVirtualMachines'
]
