Class {
	#name : 'AssignmentCollectorJava',
	#superclass : 'AssignmentCollector',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollectorJava >> assignmentNodeTypes [

	^ #( 'assignment_expression' 'variable_declarator' )
]

{ #category : 'private - accessing' }
AssignmentCollectorJava >> assignmentTargetNodeFor: aNode [

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

	^ #( 'identifier' 'field_access' 'array_access' )
]
