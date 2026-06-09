"
Represents a pending assignment detected during stack collection or analysis.

A PendingAssignment captures the state of an assignment that has not yet been
fully resolved. It is created while inspecting execution stacks when there is an assignment.
"
Class {
	#name : 'PendingAssignment',
	#superclass : 'Object',
	#instVars : [
		'object',
		'oldValue',
		'targetExpression',
		'objectExpression',
		'stackDepth',
		'lineNumber',
		'filepath'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'accessing' }
PendingAssignment >> filepath [

	^ filepath
]

{ #category : 'accessing' }
PendingAssignment >> filepath: anObject [

	filepath := anObject
]

{ #category : 'api' }
PendingAssignment >> hasBeenPassedBy: aStackTrace [
	"Return true if aStackTrace represents an execution point
    after the receiver pending assignment.
	aStackTrace is a Dictionnary, the body of StackTraceResponse"

	| currentDepth currentLine topFrame |
	currentDepth := aStackTrace at: 'totalFrames'.

	currentDepth < stackDepth ifTrue: [ ^ true ].

	currentDepth > stackDepth ifTrue: [ ^ false ].

	topFrame := (aStackTrace at: 'stackFrames') first.
	currentLine := topFrame at: 'line'.

	^ currentLine ~= lineNumber
]

{ #category : 'accessing' }
PendingAssignment >> lineNumber [

	^ lineNumber
]

{ #category : 'accessing' }
PendingAssignment >> lineNumber: anObject [

	lineNumber := anObject
]

{ #category : 'accessing' }
PendingAssignment >> object [

	^ object
]

{ #category : 'accessing' }
PendingAssignment >> object: anObject [

	object := anObject
]

{ #category : 'accessing' }
PendingAssignment >> objectExpression [

	^ objectExpression
]

{ #category : 'accessing' }
PendingAssignment >> objectExpression: anObject [

	objectExpression := anObject
]

{ #category : 'accessing' }
PendingAssignment >> oldValue [

	^ oldValue
]

{ #category : 'accessing' }
PendingAssignment >> oldValue: anObject [

	oldValue := anObject
]

{ #category : 'accessing' }
PendingAssignment >> stackDepth [

	^ stackDepth
]

{ #category : 'accessing' }
PendingAssignment >> stackDepth: anObject [

	stackDepth := anObject
]

{ #category : 'accessing' }
PendingAssignment >> targetExpression [

	^ targetExpression
]

{ #category : 'accessing' }
PendingAssignment >> targetExpression: anObject [

	targetExpression := anObject
]
