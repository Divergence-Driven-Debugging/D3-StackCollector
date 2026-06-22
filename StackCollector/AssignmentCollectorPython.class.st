Class {
	#name : 'AssignmentCollectorPython',
	#superclass : 'AssignmentCollector',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - accessing' }
AssignmentCollectorPython >> assignmentNodeTypes [

	^ #( 'assignment' 'augmented_assignment' )
]

{ #category : 'private - accessing' }
AssignmentCollectorPython >> assignmentTargetNodeFor: aNode [

	^ aNode nodeChildByFieldName: 'left'
]

{ #category : 'accessing' }
AssignmentCollectorPython >> languageToParse [
	"Return a TSLanguage"

	^ TSLanguage python
]

{ #category : 'private - accessing' }
AssignmentCollectorPython >> targetNodeTypes [

	^ #( 'identifier' 'attribute' 'subscript' )
]
