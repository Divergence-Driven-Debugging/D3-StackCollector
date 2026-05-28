Class {
	#name : 'FileLineCacheTest',
	#superclass : 'TestCase',
	#instVars : [
		'cache',
		'fileName',
		'fileRef'
	],
	#classInstVars : [
		'fileName',
		'setUp'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'running' }
FileLineCacheTest >> setUp [

	super setUp.

	cache := FileLineCache new.
	fileName := 'testFile'.
	fileRef := fileName asFileReference.

	fileRef writeStreamDo: [ :s |
			s
				nextPutAll: 'line1';
				cr;
				nextPutAll: 'line2';
				cr;
				nextPutAll: 'line3' ]
]

{ #category : 'running' }
FileLineCacheTest >> tearDown [

	fileRef delete.
	super tearDown
]

{ #category : 'tests' }
FileLineCacheTest >> testGetLineFrom [

	self assert: (cache getLine: 1 from: fileRef) equals: 'line1'.
	self assert: (cache getLine: 2 from: fileRef) equals: 'line2'.
	self assert: (cache getLine: 3 from: fileRef) equals: 'line3'
]

{ #category : 'tests' }
FileLineCacheTest >> testGetLineOutOfBounds [

	self assert: (cache getLine: 10 from: fileRef) isNil.
	self assert: (cache getLine: 0 from: fileRef) isNil
]

{ #category : 'tests' }
FileLineCacheTest >> testLoadLinesFor [

	| first second |
	first := cache loadLinesFor: fileRef.
	second := cache loadLinesFor: fileRef.
	self assert: first identicalTo: second
]

{ #category : 'tests' }
FileLineCacheTest >> testMultipleFiles [

	| file2 |
	file2 := 'testFile2.txt' asFileReference.

	file2 writeStreamDo: [ :s |
			s
				nextPutAll: 'A';
				cr;
				nextPutAll: 'B' ].

	self assert: (cache getLine: 1 from: fileRef) equals: 'line1'.
	self assert: (cache getLine: 1 from: file2) equals: 'A'.

	file2 delete
]

{ #category : 'tests' }
FileLineCacheTest >> testSecondAccessIsFast [

	| t1 t2 |
	t1 := Time millisecondClockValue.
	cache getLine: 2 from: fileRef.
	t1 := Time millisecondClockValue - t1.

	t2 := Time millisecondClockValue.
	cache getLine: 2 from: fileRef.
	t2 := Time millisecondClockValue - t2.

	self assert: t2 <= t1
]
