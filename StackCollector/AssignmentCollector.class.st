"
I extract assignment variable names from source code lines using a Tree-sitter parser.

I analyze a single line of source text, locate assignment nodes and answer the name of the assigned variable when an assignment is present. Both standard assignments and augmented assignments are supported.
"
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
AssignmentCollector >> collectAssignmentTargetsFrom: aNode source: source into: assignments [
	"Recursively collect assignment targets from the left-hand
	side of an assignment expression."

	(#( 'identifier' 'attribute' 'subscript' ) includes: aNode type)
		ifTrue: [
				assignments add: (aNode textFromSourceText: source).
				^ self ].

	"Traverse child nodes to find nested targets."
	aNode namedChildren do: [ :child |
			self
				collectAssignmentTargetsFrom: child
				source: source
				into: assignments ]
]

{ #category : 'private - accessing' }
AssignmentCollector >> collectAssignmentsFrom: aNode source: source into: assignments [
	"Recursively traverse the AST and collect assignment targets
	from assignment and augmented assignment nodes."

	(#( 'assignment' 'augmented_assignment' ) includes: aNode type)
		ifTrue: [
				| left |
				left := aNode nodeChildByFieldName: 'left'.

				left ifNotNil: [
						self
							collectAssignmentTargetsFrom: left
							source: source
							into: assignments ] ].

	"Continue traversal on child nodes."
	aNode namedChildren do: [ :child |
		self collectAssignmentsFrom: child source: source into: assignments ]
]

{ #category : 'accessing' }
AssignmentCollector >> getAssignmentNameFromLine: aString [
	
	"Return an Array of string corresponding to the assignment target"
	
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
