Class {
	#name : 'AssignmentCollectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'assignmentCollector'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'initialization' }
AssignmentCollectorTest >> initialize [
	"We ensure the installation of the library before running the tests because it could cause a time limit to fails for the test installing the libraries."

	TSLibrariesPython new ensurePythonLibraryExists
]

{ #category : 'running' }
AssignmentCollectorTest >> setUp [
	| parser |
	super setUp.

	assignmentCollector := AssignmentCollector new.
	parser := TSParser new
		          language: TSLanguage python;
		          yourself.
	assignmentCollector parser: parser
]

{ #category : 'tests' }
AssignmentCollectorTest >> testCollectAssignmentTargetsFromIdentifier [

	| node assignments |
	node := MockTSNode new
		        type: 'identifier';
		        text: 'foo'.

	assignments := OrderedCollection new.

	assignmentCollector
		collectAssignmentTargetsFrom: node
		source: ''
		into: assignments.

	self assert: assignments asArray equals: #( 'foo' )
]

{ #category : 'tests' }
AssignmentCollectorTest >> testCollectAssignmentTargetsFromNestedTargets [

	| root a b c assignments |
	a := MockTSNode new
		     type: 'identifier';
		     text: 'a';
		     yourself.

	b := MockTSNode new
		     type: 'identifier';
		     text: 'b';
		     yourself.

	c := MockTSNode new
		     type: 'identifier';
		     text: 'c';
		     yourself.

	root := MockTSNode new
		        type: 'tuple';
		        namedChildren: {
				        a.
				        b.
				        c };
		        yourself.

	assignments := OrderedCollection new.

	assignmentCollector
		collectAssignmentTargetsFrom: root
		source: ''
		into: assignments.

	self assert: assignments asArray equals: #( 'a' 'b' 'c' )
]

{ #category : 'tests' }
AssignmentCollectorTest >> testCollectAssignmentsFromAssignmentNode [

	| left assignmentNode assignments |
	left := MockTSNode new
		        type: 'identifier';
		        text: 'foo';
		        yourself.

	assignmentNode := MockTSNode new
		                  type: 'assignment';
		                  leftNode: left;
		                  yourself.

	assignments := OrderedCollection new.

	assignmentCollector
		collectAssignmentsFrom: assignmentNode
		source: ''
		into: assignments.

	self assert: assignments asArray equals: #( 'foo' )
]

{ #category : 'tests' }
AssignmentCollectorTest >> testCollectAssignmentsFromNestedAssignments [

	| left1 left2 assignment1 assignment2 root assignments |
	left1 := MockTSNode new
		         type: 'identifier';
		         text: 'foo';
		         yourself.

	left2 := MockTSNode new
		         type: 'identifier';
		         text: 'bar';
		         yourself.

	assignment1 := MockTSNode new
		               type: 'assignment';
		               leftNode: left1;
		               yourself.

	assignment2 := MockTSNode new
		               type: 'augmented_assignment';
		               leftNode: left2;
		               yourself.

	root := MockTSNode new
		        type: 'module';
		        namedChildren: {
				        assignment1.
				        assignment2 };
		        yourself.

	assignments := OrderedCollection new.

	assignmentCollector
		collectAssignmentsFrom: root
		source: ''
		into: assignments.

	self assert: assignments asArray equals: #( 'foo' 'bar' )
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
AssignmentCollectorTest >> testGetAssignmentNameFromComplexTypedAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: '(a, b): tuple[int, int] = x'.

	self assert: result equals: { 'a' . 'b' }
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

{ #category : 'tests' }
AssignmentCollectorTest >> testGetAssignmentNameFromTypedAssignment [

	| result |
	result := assignmentCollector getAssignmentNameFromLine: 'x: int = 1'.

	self assert: result equals: { 'x' }
]
