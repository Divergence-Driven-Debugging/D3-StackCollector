Class {
	#name : 'AssignmentCollector',
	#superclass : 'Object',
	#instVars : [
		'parser'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollector >> collectAssignmentTargetsFrom: aNode
	source: source
	into: assignments [

	(#( 'identifier' 'attribute' 'subscript' )
		includes: aNode type)
		ifTrue: [
			assignments add:
				(aNode textFromSourceText: source).
			^ self
		].

	aNode namedChildren do: [ :child |
		self
			collectAssignmentTargetsFrom: child
			source: source
			into: assignments
	]
]

{ #category : 'private - accessing' }
AssignmentCollector >> collectAssignmentsFrom: aNode source: source into: assignments [

	(#( 'assignment' 'augmented_assignment' ) includes: aNode type)
		ifTrue: [
				| left |
				left := aNode nodeChildByFieldName: 'left'.

				left ifNotNil: [
						self
							collectAssignmentTargetsFrom: left
							source: source
							into: assignments ] ].

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
