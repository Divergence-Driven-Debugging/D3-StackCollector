"
I am a cache for file contents indexed by file path.

I provide fast access to individual lines of text files by loading and storing their contents in memory on demand. Lines are cached the first time a file is accessed, avoiding repeated disk reads for subsequent lookups.
"
Class {
	#name : 'FileLineCache',
	#superclass : 'Object',
	#instVars : [
		'cache'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
FileLineCache >> cache [
	
	^ cache
]

{ #category : 'loading' }
FileLineCache >> getLine: aNumber from: aFileReference [

	"Answer the line at aNumber from the file referenced by
	aFileReference.

	The file contents are loaded and cached on first access.
	Answer nil if the requested line does not exist."

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
	"Answer the cached lines for aFileReference.

	If the file has not been loaded yet, read all its lines from disk,
	store them in the cache and answer the resulting array."

	^ cache at: aFileReference fullName ifAbsentPut: [
			  aFileReference readStreamDo: [ :stream |
					  Array streamContents: [ :out |
						  [ stream atEnd ] whileFalse: [ out nextPut: stream nextLine ] ] ] ]
]
