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
	"Create a DAP client configured to debug the source located at aPath
	through the adapter listening on aNumber.

	Subclasses must provide a language-specific implementation."

	^ self subclassResponsibility
]

{ #category : 'actions' }
SupportedLanguage class >> launchAdapterAtPort: aNumber [
	"Start the language-specific DAP adapter configured to accept connections on port aNumber.

	Subclasses must implement the adapter startup procedure."

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
