Class {
	#name : 'AssignmentCollectorTest',
	#superclass : 'ParametrizedTestCase',
	#instVars : [
		'assignmentCollector',
		'line',
		'expectedResult'
	],
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'building suites' }
AssignmentCollectorTest class >> testParameters [

	^ ParametrizedTestMatrix new
		  addCase: {
				  (#line -> 'obj.foo = bar').
				  (#expectedResult -> #( 'obj.foo' )) };
		  addCase: {
				  (#line -> 'x += 1').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'a = b = c = d').
				  (#expectedResult -> #( 'a' 'b' 'c' )) };
		  addCase: {
				  (#line -> '(a, (b, c)) = x').
				  (#expectedResult -> #( 'a' 'b' 'c' )) };
		  addCase: {
				  (#line -> '(a, b): tuple[int, int] = x').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> '[a, b] = x').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'a, b, c, d, e, f = 1, 2, 3, 4, 5, 6').
				  (#expectedResult -> #( 'a' 'b' 'c' 'd' 'e' 'f' )) };
		  addCase: {
				  (#line -> 'x = 1; y = 2').
				  (#expectedResult -> #( 'x' 'y' )) };
		  addCase: {
				  (#line -> 'print(x)').
				  (#expectedResult -> #(  )) };
		  addCase: {
				  (#line -> 'x = 1').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'a, *rest = x').
				  (#expectedResult -> #( 'a' 'rest' )) };
		  addCase: {
				  (#line -> 'arr[0] = 1').
				  (#expectedResult -> #( 'arr[0]' )) };
		  addCase: {
				  (#line -> 'a, b = 1, 2').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'x: int = 1').
				  (#expectedResult -> #( 'x' )) };
		  yourself
]

{ #category : 'accessing' }
AssignmentCollectorTest >> expectedResult [

	^ expectedResult
]

{ #category : 'accessing' }
AssignmentCollectorTest >> expectedResult: aCollection [

	expectedResult := aCollection
]

{ #category : 'initialization' }
AssignmentCollectorTest >> initialize [
	"We ensure the installation of the library before running the tests because it could cause a time limit to fails for the test installing the libraries."

	TSLibrariesPython new ensurePythonLibraryExists
]

{ #category : 'accessing' }
AssignmentCollectorTest >> line [
	
	^ line
]

{ #category : 'accessing' }
AssignmentCollectorTest >> line: aString [

	line := aString
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
AssignmentCollectorTest >> testGetAssignmentNameFromLine [

	self
		assert: (assignmentCollector getAssignmentNameFromLine: line)
		equals: expectedResult
]
