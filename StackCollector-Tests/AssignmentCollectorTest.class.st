Class {
	#name : 'AssignmentCollectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'assignmentCollector'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'running' }
AssignmentCollectorTest >> setUp [
	| parser pythonLanguage |
	super setUp.

	assignmentCollector := AssignmentCollector new.
	parser := TSParser new.
	pythonLanguage := TSLanguage python.
	parser language: pythonLanguage.
	assignmentCollector parser: parser.
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromAttributeAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'obj.foo = bar'.

	self assert: result equals: { 'obj.foo' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromAugmentedAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'x += 1'.

	self assert: result equals: { 'x' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromChainedAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine:
		          'a = b = c = d'.

	self assert: result equals: { 'a'. 'b'. 'c' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromCompleTupleAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine:
		          '(a, (b, c)) = x'.

	self assert: result equals: { 'a'. 'b'. 'c' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromListUnpacking [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: '[a, b] = x'.

	self assert: result equals: { 'a' . 'b' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromLongTupleAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine:
		          'a, b, c, d, e, f = 1, 2, 3, 4, 5, 6'.

	self assert: result equals: { 'a'. 'b'. 'c'. 'd'. 'e'. 'f' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromMultipleAssignments [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'x = 1; y = 2'.

	self assert: result equals: { 'x' . 'y' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromNoAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'print(x)'.

	self assert: result equals: { }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromSimpleLine [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'x = 1'.

	self assert: result equals: { 'x' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromStarUnpacking [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'a, *rest = x'.

	self assert: result equals: { 'a' . 'rest' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromSubscriptAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'arr[0] = 1'.

	self assert: result equals: { 'arr[0]' }
]

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromTupleAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'a, b = 1, 2'.

	self assert: result equals: { 'a' . 'b' }
]
