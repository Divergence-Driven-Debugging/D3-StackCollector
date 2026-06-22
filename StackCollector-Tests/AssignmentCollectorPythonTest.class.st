Class {
	#name : 'AssignmentCollectorPythonTest',
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
AssignmentCollectorPythonTest class >> testParameters [

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
AssignmentCollectorPythonTest >> expectedResult [

	^ expectedResult
]

{ #category : 'accessing' }
AssignmentCollectorPythonTest >> expectedResult: aCollection [

	expectedResult := aCollection
]

{ #category : 'initialization' }
AssignmentCollectorPythonTest >> initialize [
	"We ensure the installation of the library before running the tests because it could cause a time limit to fails for the test installing the libraries."

	TSLibrariesPython new ensurePythonLibraryExists
]

{ #category : 'accessing' }
AssignmentCollectorPythonTest >> line [
	
	^ line
]

{ #category : 'accessing' }
AssignmentCollectorPythonTest >> line: aString [

	line := aString
]

{ #category : 'running' }
AssignmentCollectorPythonTest >> setUp [

	super setUp.
	self parametersToUse do: [ :aParameter | aParameter applyTo: self ].

	"If I am executed without calling buildSuite in the class. I will use the first set of options.
	This is a workaround to work when running from Calypso"
	(self parametersToUse isEmpty and: [
		 self class testParameters isNotEmpty ]) ifTrue: [
			self class testParameters expandMatrix first do: [ :aParameter |
				aParameter applyTo: self ] ].

	assignmentCollector := AssignmentCollectorPython new
]

{ #category : 'tests' }
AssignmentCollectorPythonTest >> testGetAssignmentNameFromLine [

	self
		assert: (assignmentCollector getAssignmentNameFromLine: line)
		equals: expectedResult
]
