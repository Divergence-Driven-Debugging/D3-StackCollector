Class {
	#name : 'PendingAssignmentTest',
	#superclass : 'TestCase',
	#category : 'StackCollector-Tests',
	#package : 'StackCollector-Tests'
}

{ #category : 'helper' }
PendingAssignmentTest >> helperCreateStackFrameDepth: depth line: line [
	"Create a DAP StackTrace-like response for hasBeenPassed tests, where only the stack frame depth and the line number of the top stack frame are relevant."

	^ {
		  ('totalFrames' -> depth).
		  ('stackFrames' -> { { ('line' -> line) } asDictionary }) }
		  asDictionary
]

{ #category : 'testing' }
PendingAssignmentTest >> testHasBeenPassedBy [

	| aPendingAssignment sameDepthBeforeLine sameDepthAndLine sameDepthAfterLine smallerDepth biggerDepth |
	aPendingAssignment := PendingAssignment new
		                      stackDepth: 2;
		                      lineNumber: 10.

	sameDepthBeforeLine := self helperCreateStackFrameDepth: 2 line: 9.
	sameDepthAndLine := self helperCreateStackFrameDepth: 2 line: 10.
	sameDepthAfterLine := self helperCreateStackFrameDepth: 2 line: 11.

	smallerDepth := self helperCreateStackFrameDepth: 1 line: 9.
	biggerDepth := self helperCreateStackFrameDepth: 3 line: 11.

	self assert:
		(aPendingAssignment hasBeenPassedBy: sameDepthBeforeLine). "can happend in a loop"
	self deny: (aPendingAssignment hasBeenPassedBy: sameDepthAndLine).
	self assert: (aPendingAssignment hasBeenPassedBy: sameDepthAfterLine).

	self assert: (aPendingAssignment hasBeenPassedBy: smallerDepth).
	self deny: (aPendingAssignment hasBeenPassedBy: biggerDepth)
]
