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
AssignmentCollector >> assignmentNodeTypes [
	"Answer the collection of AST node types that represent assignment for the target language."

	^ self subclassResponsibility
]

{ #category : 'private - accessing' }
AssignmentCollector >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	^ self subclassResponsibility
]

{ #category : 'private - accessing' }
AssignmentCollector >> collectAssignmentTargetsFrom: aNode source: source into: assignments [
	"Recursively collect assignment targets from the left-hand
	side of an assignment expression."

	(self targetNodeTypes includes: aNode type) ifTrue: [
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

	(self assignmentNodeTypes includes: aNode type) ifTrue: [
			| target |
			target := self assignmentTargetNodeFor: aNode.

			target ifNotNil: [
					self
						collectAssignmentTargetsFrom: target
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

	self collectAssignmentsFrom: root source: aString into: assignments.

	^ assignments asArray
]

{ #category : 'initialization' }
AssignmentCollector >> initialize [

	super initialize.

	parser := TSParser new
		          language: self languageToParse;
		          yourself
]

{ #category : 'accessing' }
AssignmentCollector >> languageToParse [
	"Return the target language, a TSLanguage"

	^ self subclassResponsibility
]

{ #category : 'private - accessing' }
AssignmentCollector >> targetNodeTypes [
	"Answer the collection of AST node types that can be considered valid assignment targets for the target language."

	^ self subclassResponsibility
]
