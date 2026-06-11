Class {
	#name : 'TraceCollector',
	#superclass : 'Object',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'collect' }
TraceCollector >> collectFor: aSupportedLanguage path: aPath [

	| clientDAP res |
	aSupportedLanguage launchAdapterAtPort: self port.

	1 seconds asDuration wait.

	clientDAP := aSupportedLanguage
		             createClientFor: aPath
		             atPort: self port.

	1 seconds asDuration wait.

	res := (DAPTraceCollector collectStackFrom: clientDAP) asArray.
	clientDAP closeConnection.
	^ res
]

{ #category : 'accessing' }
TraceCollector >> port [
	
	^ 5678
]
