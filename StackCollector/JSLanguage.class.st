Class {
	#name : 'JSLanguage',
	#superclass : 'SupportedLanguage',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
JSLanguage class >> assignmentTargetNodeFor: aNode [
	"Answer the AST node corresponding to the assignment target of the given assignment node.
	Answer nil if the assignment node has no target."

	aNode type = 'assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	aNode type = 'variable_declarator' ifTrue: [
		^ aNode nodeChildByFieldName: 'name' ].

	aNode type = 'augmented_assignment_expression' ifTrue: [
		^ aNode nodeChildByFieldName: 'left' ].

	^ nil
]

{ #category : 'testing' }
JSLanguage class >> isAssignmentNode: aNode [
	"Answer wether aNode an assignment for the target language."

	^ #( 'assignment_expression' 'augmented_assignment_expression'
	     'variable_declarator' ) includes: aNode type
]

{ #category : 'testing' }
JSLanguage class >> isTerminalTargetNode: aNode [

	^ #( 'identifier' 'member_expression' 'subscript_expression'
	     'shorthand_property_identifier_pattern' ) includes: aNode type
]

{ #category : 'accessing' }
JSLanguage class >> languageToParse [
	"Return the target language, a TSLanguage"

	^ TSLanguage typescript
]
