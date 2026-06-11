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
