"
I specialize AssignmentCollector for Java source code.

I define the Java-specific AST node types and target extraction rules required to identify assignment targets.
"
Class {
	#name : 'AssignmentCollectorJava',
	#superclass : 'AssignmentCollector',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollectorJava >> assignmentNodeTypes [
	"Answer the collection of AST node types that represent assignment for the target language."

	^ #( 'assignment_expression' 'variable_declarator' )
]

{ #category : 'private - accessing' }
AssignmentCollectorJava >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	aNode type = 'assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	aNode type = 'variable_declarator' ifTrue: [
		^ aNode nodeChildByFieldName: 'name' ].

	^ nil
]

{ #category : 'accessing' }
AssignmentCollectorJava >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage java
]

{ #category : 'private - accessing' }
AssignmentCollectorJava >> targetNodeTypes [
	"Answer the collection of AST node types that can be considered valid assignment targets for the target language."

	^ #( 'identifier' 'field_access' 'array_access' )
]
