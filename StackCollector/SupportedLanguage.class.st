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

{ #category : 'actions' }
SupportedLanguage class >> createClientFor: aPath atPort: aNumber [

	^ self subclassResponsibility
]

{ #category : 'actions' }
SupportedLanguage class >> launchAdapterAtPort: aNumber [

	^ self subclassResponsibility
]

{ #category : 'actions' }
SupportedLanguage >> createClientFor: aPath atPort: aNumber [

	^ self class createClientFor: aPath atPort: aNumber
]

{ #category : 'actions' }
SupportedLanguage >> launchAdapterAtPort: aNumber [

	self class launchAdapterAtPort: aNumber
]
