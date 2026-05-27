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

	fileRef exists ifTrue: [ fileRef delete ].
	super tearDown
]

{ #category : 'tests' }
FileLineCacheTest >> testCacheIsUsed [

	| first second |
	first := cache loadLinesFor: fileName.
	second := cache loadLinesFor: fileName.
	self assert: first identicalTo: second
]

{ #category : 'tests' }
FileLineCacheTest >> testGetLineBasic [

	self assert: (cache getLine: 1 from: fileName) equals: 'line1'.
	self assert: (cache getLine: 2 from: fileName) equals: 'line2'.
	self assert: (cache getLine: 3 from: fileName) equals: 'line3'
]

{ #category : 'tests' }
FileLineCacheTest >> testGetLineOutOfBounds [

	self assert: (cache getLine: 10 from: fileName) isNil.
	self assert: (cache getLine: 0 from: fileName) isNil
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

	self assert: (cache getLine: 1 from: fileName) equals: 'line1'.
	self assert: (cache getLine: 1 from: file2 fullName) equals: 'A'.

	file2 delete
]

{ #category : 'tests' }
FileLineCacheTest >> testSecondAccessIsFast [

	| t1 t2 |
	t1 := Time millisecondClockValue.
	cache getLine: 2 from: fileName.
	t1 := Time millisecondClockValue - t1.

	t2 := Time millisecondClockValue.
	cache getLine: 2 from: fileName.
	t2 := Time millisecondClockValue - t2.

	self assert: t2 <= t1
]
