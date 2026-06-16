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

{ #category : 'actions' }
PythonLanguage class >> createClientFor: aPath atPort: aNumber [

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

{ #category : 'actions' }
PythonLanguage class >> launchAdapterAtPort: aNumber [

	AdapterLauncher launchPythonAdapterAtPort: aNumber
]
