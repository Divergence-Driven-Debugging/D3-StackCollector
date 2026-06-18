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

{ #category : 'actions' }
JavaLanguage class >> launchAdapterAtPort: aNumber [
	"Start the java adapter configured to accept connections on port aNumber."

	AdapterLauncher launchJavaAdapterAtPort: aNumber
]
