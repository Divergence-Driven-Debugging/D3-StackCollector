Class {
	#name : 'AssignmentCollectorJSTest',
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
AssignmentCollectorJSTest class >> testParameters [

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
				  (#line -> '[a, [b, c]] = x').
				  (#expectedResult -> #( 'a' 'b' 'c' )) };
		  addCase: {
				  (#line -> '[a, b] = x').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'let [a, b] = x').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'let [a, b, c, d, e, f] = [1, 2, 3, 4, 5, 6]').
				  (#expectedResult -> #( 'a' 'b' 'c' 'd' 'e' 'f' )) };
		  addCase: {
				  (#line -> 'x = 1; y = 2').
				  (#expectedResult -> #( 'x' 'y' )) };
		  addCase: {
				  (#line -> 'console.log(x)').
				  (#expectedResult -> #(  )) };
		  addCase: {
				  (#line -> 'x = 1').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'let [a, ...rest] = x').
				  (#expectedResult -> #( 'a' 'rest' )) };
		  addCase: {
				  (#line -> 'arr[0] = 1').
				  (#expectedResult -> #( 'arr[0]' )) };
		  addCase: {
				  (#line -> 'let [a, b] = [1, 2]').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'let x = 1').
				  (#expectedResult -> #( 'x' )) };
		  addCase: {
				  (#line -> 'let {a, b} = x').
				  (#expectedResult -> #( 'a' 'b' )) };
		  addCase: {
				  (#line -> 'let {a: {b, c}} = x').
				  (#expectedResult -> #( 'b' 'c' )) };
		  addCase: {
				  (#line -> 'let {a, ...rest} = x').
				  (#expectedResult -> #( 'a' 'rest' )) };
		  addCase: {
				  (#line -> 'foo(x, y)').
				  (#expectedResult -> #(  )) };
		  addCase: {
				  (#line -> '({a} = x)').
				  (#expectedResult -> #( 'a' )) };
		  yourself
]

{ #category : 'accessing' }
AssignmentCollectorJSTest >> expectedResult [

	^ expectedResult
]

{ #category : 'accessing' }
AssignmentCollectorJSTest >> expectedResult: aCollection [

	expectedResult := aCollection
]

{ #category : 'initialization' }
AssignmentCollectorJSTest >> initialize [
	"We ensure the installation of the library before running the tests because it could cause a time limit to fails for the test installing the libraries."

	TSLibrariesTypescript new ensureTypescriptLibraryExists
]

{ #category : 'accessing' }
AssignmentCollectorJSTest >> line [
	
	^ line
]

{ #category : 'accessing' }
AssignmentCollectorJSTest >> line: aString [

	line := aString
]

{ #category : 'running' }
AssignmentCollectorJSTest >> setUp [

	super setUp.
	self parametersToUse do: [ :aParameter | aParameter applyTo: self ].

	"If I am executed without calling buildSuite in the class. I will use the first set of options.
	This is a workaround to work when running from Calypso"
	(self parametersToUse isEmpty and: [
		 self class testParameters isNotEmpty ]) ifTrue: [
			self class testParameters expandMatrix first do: [ :aParameter |
				aParameter applyTo: self ] ].

	assignmentCollector := AssignmentCollector new
]

{ #category : 'tests' }
AssignmentCollectorJSTest >> testGetAssignmentNameFromLine [

	self
		assert:
		(assignmentCollector getAssignmentNameFromLine: line for: JSLanguage)
		equals: expectedResult
]
