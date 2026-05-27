Class {
	#name : 'FileLineCache',
	#superclass : 'Object',
	#instVars : [
		'cache'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'loading' }
FileLineCache >> getLine: aNumber from: aString [

	| lines |
	lines := self loadLinesFor: aString.
	^ lines at: aNumber ifAbsent: [ nil ]
]

{ #category : 'initialization' }
FileLineCache >> initialize [

	super initialize.
	cache := Dictionary new
]

{ #category : 'loading' }
FileLineCache >> loadLinesFor: aString [

	^ cache at: aString ifAbsentPut: [
			  aString asFileReference readStreamDo: [ :stream |
					  Array streamContents: [ :out |
						  [ stream atEnd ] whileFalse: [ out nextPut: stream nextLine ] ] ] ]
]
