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
FileLineCache >> getLine: aNumber from: aFileReference [

	| lines |
	lines := self loadLinesFor: aFileReference.
	^ lines at: aNumber ifAbsent: [ nil ]
]

{ #category : 'initialization' }
FileLineCache >> initialize [

	super initialize.
	cache := Dictionary new
]

{ #category : 'loading' }
FileLineCache >> loadLinesFor: aFileReference [

	^ cache at: aFileReference fullName ifAbsentPut: [
			  aFileReference readStreamDo: [ :stream |
					  Array streamContents: [ :out |
						  [ stream atEnd ] whileFalse: [ out nextPut: stream nextLine ] ] ] ]
]
