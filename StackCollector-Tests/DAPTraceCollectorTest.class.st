Class {
	#name : 'DAPTraceCollectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'collector'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'running' }
DAPTraceCollectorTest >> setUp [

	super setUp.
	collector := DAPTraceCollector new
]

{ #category : 'tests' }
DAPTraceCollectorTest >> testFormatPath [

	collector projectPath: '/a/b/c/d'.

	self
		assert: (collector formatPath: '/a/b/c/d/file.st')
		equals: 'file.st'.
	self
		assert: (collector formatPath: '/a/b/c/d/e/file.st')
		equals: 'e/file.st'.
	self
		assert: (collector formatPath: '/a/b/file.st')
		equals: '../../file.st'
]
