Class {
	#name : 'AssignmentCollector',
	#superclass : 'Object',
	#instVars : [
		'parser'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
AssignmentCollector >> collectAssignmentsFrom: aNode source: source into: assignments [

	(#( 'assignment' 'augmented_assignment' ) includes: aNode type)
		ifTrue: [
				| left |
				left := aNode nodeChildByFieldName: 'left'.

				left ifNotNil: [
					assignments add: (left textFromSourceText: source) ] ].

	aNode namedChildren do: [ :child |
		self collectAssignmentsFrom: child source: source into: assignments ]
]

{ #category : 'accessing' }
AssignmentCollector >> getAssignmentNameFromLine: aString [

	| root assignments |
	
	root := (parser parseString: aString) rootNode.

	assignments := OrderedCollection new.

	self
		collectAssignmentsFrom: root
		source: aString
		into: assignments.

	^ assignments asArray
]

{ #category : 'accessing' }
AssignmentCollector >> parser [

	^ parser
]

{ #category : 'accessing' }
AssignmentCollector >> parser: aTSParser [

	parser := aTSParser
]
