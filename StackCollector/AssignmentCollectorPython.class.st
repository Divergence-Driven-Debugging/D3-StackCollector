"
I specialize AssignmentCollector for Python source code.

I define the Python-specific AST node types and target extraction rules required to identify assignment targets.
"
Class {
	#name : 'AssignmentCollectorPython',
	#superclass : 'AssignmentCollector',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollectorPython >> assignmentNodeTypes [
	"Answer the collection of AST node types that represent assignment for the target language."

	^ #( 'assignment' 'augmented_assignment' )
]

{ #category : 'private - accessing' }
AssignmentCollectorPython >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	^ aNode nodeChildByFieldName: 'left'
]

{ #category : 'accessing' }
AssignmentCollectorPython >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage python
]

{ #category : 'private - accessing' }
AssignmentCollectorPython >> targetNodeTypes [
	"Answer the collection of AST node types that can be considered valid assignment targets for the target language."

	^ #( 'identifier' 'attribute' 'subscript' )
]
