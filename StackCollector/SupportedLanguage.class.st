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
