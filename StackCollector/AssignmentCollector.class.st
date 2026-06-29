"
I extract assignment variable names from source code lines using a Tree-sitter parser.

I analyze a single line of source text, locate assignment nodes and answer the name of the assigned variable when an assignment is present. Both standard assignments and augmented assignments are supported.
"
Class {
	#name : 'AssignmentCollector',
	#superclass : 'Object',
	#instVars : [
		'supportedLanguage'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollector >> collectAssignmentsFrom: aNode source: source into: assignments [
	"Recursively traverse the AST and collect assignment targets
	from assignment and augmented assignment nodes."

	(supportedLanguage isAssignmentNode: aNode) ifTrue: [
			| target |
			target := supportedLanguage assignmentTargetNodeFor: aNode.

			target ifNotNil: [
				self collectTargetsFrom: target source: source into: assignments ] ].

	"Continue traversal on child nodes."
	aNode namedChildren do: [ :child |
		self collectAssignmentsFrom: child source: source into: assignments ]
]

{ #category : 'private - accessing' }
AssignmentCollector >> collectTargetsFrom: aNode source: source into: assignments [
	"Recursively collect assignment targets from the left-hand	side of an assignment expression."

	(supportedLanguage isTerminalTargetNode: aNode) ifTrue: [
			assignments add: (aNode textFromSourceText: source).
			^ self ].

	aNode namedChildren do: [ :child |
		self collectTargetsFrom: child source: source into: assignments ]
]

{ #category : 'accessing' }
AssignmentCollector >> getAssignmentNameFromLine: aString for: aSupportedLanguage [
	"Return an Array of string corresponding to the assignment target"

	| parser root assignments |
	supportedLanguage := aSupportedLanguage.
	parser := TSParser new
		          language: aSupportedLanguage languageToParse;
		          yourself.
	root := (parser parseString: aString) rootNode.

	assignments := OrderedCollection new.

	self collectAssignmentsFrom: root source: aString into: assignments.

	^ assignments asArray
]
