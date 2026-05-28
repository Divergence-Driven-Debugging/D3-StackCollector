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
AssignmentCollector >> getAssignmentNameFromLine: aString [

	| root assignmentNode left |
	root := (parser parseString: aString) rootNode.
	assignmentNode := self getAssignmentNodeFrom: root.

	assignmentNode ifNil: [ ^ nil ].

	left := assignmentNode firstNamedChild.

	^ left textFromSourceText: aString
]

{ #category : 'helper' }
AssignmentCollector >> getAssignmentNodeFrom: aTree [
	"Return the assignment TSNode found in aTree.
	Return nil if none is found."

	| node |
	node := aTree firstNamedChild.
	node isNull ifTrue: [ ^ nil ].

	node := node firstNamedChild.
	node isNull ifTrue: [ ^ nil ].
	(#( 'assignment' 'augmented_assignment' ) includes: node type)
		ifFalse: [ ^ nil ].

	^ node
]

{ #category : 'accessing' }
AssignmentCollector >> parser [

	^ parser
]

{ #category : 'accessing' }
AssignmentCollector >> parser: aTSParser [

	parser := aTSParser
]
