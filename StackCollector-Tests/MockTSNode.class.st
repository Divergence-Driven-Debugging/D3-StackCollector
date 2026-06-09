"
This is a class to Mock TSNode for AssignmentCollectorTest
"
Class {
	#name : 'MockTSNode',
	#superclass : 'Object',
	#instVars : [
		'type',
		'text',
		'leftNode',
		'namedChildren'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'accessing' }
MockTSNode >> leftNode [

	^ leftNode
]

{ #category : 'accessing' }
MockTSNode >> leftNode: anObject [

	leftNode := anObject
]

{ #category : 'api' }
MockTSNode >> namedChildren [

	^ namedChildren ifNil: [ #(  ) ]
]

{ #category : 'api' }
MockTSNode >> namedChildren: aCollection [

	^ namedChildren := aCollection
]

{ #category : 'accessing' }
MockTSNode >> nodeChildByFieldName: aString [

	aString = 'left' ifTrue: [ ^ leftNode ].
	^ nil
]

{ #category : 'accessing' }
MockTSNode >> text: aString [

	text := aString
]

{ #category : 'accessing' }
MockTSNode >> textFromSourceText [

	^ text
]

{ #category : 'accessing' }
MockTSNode >> textFromSourceText: anObject [

	^ text
]

{ #category : 'accessing' }
MockTSNode >> type [

	^ type
]

{ #category : 'accessing' }
MockTSNode >> type: anObject [

	type := anObject
]
