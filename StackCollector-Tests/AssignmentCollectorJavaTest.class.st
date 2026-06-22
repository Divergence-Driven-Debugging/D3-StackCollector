Class {
	#name : 'AssignmentCollectorJavaTest',
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
AssignmentCollectorJavaTest class >> testParameters [

	^ ParametrizedTestMatrix new
		  addCase: {
				  (#line -> 'obj.foo = bar;').
				  (#expectedResult -> #( 'obj.foo' )) };
		  addCase: {
				  (#line -> 'x += 1;').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'String a = b = c = d;').
				  (#expectedResult -> #( 'a' 'b' 'c' )) };
		  addCase: {
				  (#line -> 'float x = 1; double y = 2;').
				  (#expectedResult -> #( 'x' 'y' )) };
		  addCase: {
				  (#line -> 'System.out.println(x);').
				  (#expectedResult -> #(  )) };
		  addCase: {
				  (#line -> 'x = 1;').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'arr[0] = 1;').
				  (#expectedResult -> #( 'arr[0]' )) };
		  addCase: {
				  (#line -> 'int x = 1;').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'String name = "Bob";').
				  (#expectedResult -> #( 'name' )) };
		  addCase: {
				  (#line -> 'int x = 1, y = 2;').
				  (#expectedResult -> #( 'x' 'y' )) };
		  addCase: {
				  (#line -> 'final int count = 42;').
				  (#expectedResult -> #( 'count' )) };
		  addCase: {
				  (#line -> 'this.value = value;').
				  (#expectedResult -> #( 'this.value' )) };
		  addCase: {
				  (#line -> 'myObject.field += 10;').
				  (#expectedResult -> #( 'myObject.field' )) };
		  addCase: {
				  (#line -> 'for(int i = 0; i < 10; i ++)').
				  (#expectedResult -> #( 'i' )) };
		  yourself
]

{ #category : 'accessing' }
AssignmentCollectorJavaTest >> expectedResult [

	^ expectedResult
]

{ #category : 'accessing' }
AssignmentCollectorJavaTest >> expectedResult: aCollection [

	expectedResult := aCollection
]

{ #category : 'accessing' }
AssignmentCollectorJavaTest >> initialize [
	"We ensure the installation of the library before running the tests because it could cause a time limit to fails for the test installing the libraries."

	TSLibrariesJava new ensureJavaLibraryExists
]

{ #category : 'accessing' }
AssignmentCollectorJavaTest >> line [
	
	^ line
]

{ #category : 'accessing' }
AssignmentCollectorJavaTest >> line: aString [

	line := aString
]

{ #category : 'running' }
AssignmentCollectorJavaTest >> setUp [

	super setUp.
	self parametersToUse do: [ :aParameter | aParameter applyTo: self ].

	"If I am executed without calling buildSuite in the class. I will use the first set of options.
	This is a workaround to work when running from Calypso"
	(self parametersToUse isEmpty and: [
		 self class testParameters isNotEmpty ]) ifTrue: [
			self class testParameters expandMatrix first do: [ :aParameter |
				aParameter applyTo: self ] ].

	assignmentCollector := AssignmentCollectorJava new
]

{ #category : 'tests' }
AssignmentCollectorJavaTest >> testGetAssignmentNameFromLine [

	self
		assert: (assignmentCollector getAssignmentNameFromLine: line)
		equals: expectedResult
]
