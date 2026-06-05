"
I am collecting the execution traces from an executing programme
https://github.com/RemiDufloer/Trace-Model-Design
"
Class {
	#name : 'StackCollector',
	#superclass : 'Object',
	#instVars : [
		'clientDap',
		'id',
		'assignmentCollector',
		'fileLineCache',
		'pendingAssignmentsStack'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'initialization' }
StackCollector class >> collectStackFrom: aDAPClient [

	| collector |
	collector := self new clientDap: aDAPClient.

	^ collector getExecutionTraces
]

{ #category : 'helpers' }
StackCollector >> addAssignmentTraceFrom: currentFrameBody to: traces [

	| assignment |
	assignment := self popPendingAssignment: currentFrameBody.

	assignment ifNotNil: [ traces add: assignment ].

	self pushPendingAssignment: currentFrameBody
]

{ #category : 'helpers' }
StackCollector >> addCallTraceTo: traces [

	traces addAll: self currentCallTraces
]

{ #category : 'helpers' }
StackCollector >> argumentsForFrame: aReceiverFrame [

	| variableReference |
	variableReference := (clientDap scopesForFrame:
		                      (aReceiverFrame at: 'id')) first at:
		                     'variablesReference'.

	^ (clientDap variablesForReference: variableReference)
		  select: [ :each | (each at: 'type') isNotEmpty ]
		  thenCollect: [ :each |
			  self transformVariables: each with: (aReceiverFrame at: 'id') ]
]

{ #category : 'accessing' }
StackCollector >> clientDap [

	^ clientDap
]

{ #category : 'accessing' }
StackCollector >> clientDap: aDAPClient [

	clientDap := aDAPClient
]

{ #category : 'helpers' }
StackCollector >> currentCallTraces [

	| frames senderFrame receiverFrame arguments |
	frames := clientDap stackFrames: clientDap mainThreadId.
	senderFrame := frames second.
	receiverFrame := frames first.

	arguments := self argumentsForFrame: receiverFrame.

	^ {
		  (self
			   getMessageFrom: receiverFrame
			   and: senderFrame
			   withArguments: arguments).
		  (self getMethodFrom: receiverFrame and: senderFrame) }
]

{ #category : 'helpers' }
StackCollector >> executedCodeForFrame: aFrame [

	^ {
		  ('file' -> (aFrame at: 'source' at: 'path')).
		  ('line' -> (aFrame at: 'line')) } asDictionary
]

{ #category : 'accessing' }
StackCollector >> getExecutionTraces [
	"Return the execution trace from the dap client connected to a debugger"

	| traces |
	traces := OrderedCollection new.

	self initializeExecutionTracing.

	clientDap
		stepUntil: [ false ]
		do: [ self processCurrentStepInto: traces ].

	^ traces
]

{ #category : 'helpers' }
StackCollector >> getMessageFrom: aReceiverFrame and: aSenderFrame withArguments: aCollectionOfVariables [
	"Returns the dictionnay corresponding to the message call from a sender to a receiver"

	^ Dictionary new
		  at: 'type' put: 'message';
		  at: 'id' put: self id;
		  at: 'message_name' put: (aReceiverFrame at: 'name');
		  at: 'sender'
		  put:
			  (self hashVariable: clientDap sender in: (aSenderFrame at: 'id'));
		  at: 'receiver'
		  put:
			  (self
				   hashVariable: clientDap receiver
				   in: (aReceiverFrame at: 'id'));
		  at: 'args' put: aCollectionOfVariables;
		  at: 'executed_code'
		  put: (self executedCodeForFrame: aSenderFrame);
		  yourself
]

{ #category : 'helpers' }
StackCollector >> getMethodFrom: aReceiverFrame and: aSenderFrame [
	"Returns the dictionnay corresponding to the method from a receiver"

	^ Dictionary new
		  at: 'type' put: 'method';
		  at: 'id' put: self id;
		  at: 'sender'
		  put:
			  (self hashVariable: clientDap sender in: (aSenderFrame at: 'id'));
		  at: 'receiver'
		  put:
			  (self
				   hashVariable: clientDap receiver
				   in: (aReceiverFrame at: 'id'));
		  at: 'method_name' put: (aReceiverFrame at: 'name');
		  at: 'executed_code'
		  put: (self executedCodeForFrame: aReceiverFrame);
		  yourself
]

{ #category : 'helpers' }
StackCollector >> hashExpression: aString in: aFrameId [
	"Tranforms a dap Variable to the expected argument format"

	| evalResponse |
	evalResponse := clientDap
		                evaluate: aString
		                frameId: aFrameId
		                onErrorDo: [ ^ nil ].
		
	evalResponse
		at: 'evaluateName'
		put: aString.
		
	^ self hashVariable: evalResponse in: aFrameId
]

{ #category : 'helpers' }
StackCollector >> hashVariable: aDictionary in: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	aDictionary ifNil: [ ^ nil ].

	^ Dictionary new
		  at: 'class'
		  put: (aDictionary at: 'type' ifAbsent: 'Class Unknown');
		  at: 'hash' put: ((clientDap
				    evaluate: 'id(' , (aDictionary at: 'evaluateName') , ')'
				    frameId: aReceiverFrameId
				    onErrorDo: [
						    Dictionary new
							    at: 'result' put: 'ERROR';
							    yourself ]) at: 'result');
		  yourself
]

{ #category : 'accessing' }
StackCollector >> id [
	"Returns the current unique identifier and increments it for the next use."

	| result |
	result := id.
	id := id + 1.
	^ result
]

{ #category : 'initialization' }
StackCollector >> initialize [

	| parser pythonLanguage |
	super initialize.

	assignmentCollector := AssignmentCollector new.
	parser := TSParser new.
	pythonLanguage := TSLanguage python.
	parser language: pythonLanguage.
	assignmentCollector parser: parser.
	fileLineCache := FileLineCache new.
	pendingAssignmentsStack := Stack new
]

{ #category : 'helpers' }
StackCollector >> initializeExecutionTracing [

	clientDap initializeDapRegistry.
	clientDap stackFrames: clientDap mainThreadId. "Need one stacktrace request for clientDap hasEnteredNewCall"
	id := 1
]

{ #category : 'helpers' }
StackCollector >> popPendingAssignment: aStackTrace [
	"Pop a PendingAssignment if the top of aStackTrace is after the pendingAssignment corresponding frame.
	aStackTrace is the body of a StackTraceResponse"

	| topPendingAssignment topFrameId assignment |
	pendingAssignmentsStack isEmpty ifTrue: [ ^ nil ].

	topPendingAssignment := pendingAssignmentsStack top.

	(topPendingAssignment hasBeenPassedBy: aStackTrace) ifFalse: [ ^ nil ].
	topFrameId := (aStackTrace at: 'stackFrames') first at: 'id'.
	pendingAssignmentsStack pop.

	assignment := Dictionary new
		              at: 'type' put: 'assignment';
		              at: 'id' put: self id;
		              at: 'object' put: topPendingAssignment object;
		              at: 'variable'
		              put: topPendingAssignment targetExpression;
		              at: 'old_value' put: topPendingAssignment oldValue;
		              at: 'executed_code' put: {
				              ('file' -> topPendingAssignment filepath).
				              ('line' -> topPendingAssignment lineNumber) }
				              asDictionary;
		              yourself.

	topPendingAssignment object
		ifNil: [
				assignment at: 'new_value' put: (self
						 hashExpression: topPendingAssignment targetExpression
						 in: topFrameId) ]
		ifNotNil: [
				assignment at: 'new_value' put: (self
						 hashExpression: topPendingAssignment objectExpression , '.'
							 , topPendingAssignment targetExpression
						 in: topFrameId) ].
	^ assignment
]

{ #category : 'helpers' }
StackCollector >> processCurrentStepInto: traces [

	| hasEnteredNewCall currentFrameBody |
	hasEnteredNewCall := clientDap hasEnteredNewCall.
	currentFrameBody := clientDap currentFrameBody.

	(self shouldSkipFrameBody: currentFrameBody)
		ifTrue: [ clientDap stepOut ]
		ifFalse: [
				hasEnteredNewCall ifTrue: [ self addCallTraceTo: traces ].
				self addAssignmentTraceFrom: currentFrameBody to: traces ]
]

{ #category : 'helpers' }
StackCollector >> pushPendingAssignment: aStackTrace [
	"Push a PendingAssignment if the top of aStackTrace is an assignments.
	aStackTrace is the body of a StackTraceResponse"

	| topFrame path line frameId names depth top |
	topFrame := (aStackTrace at: 'stackFrames') first.
	path := topFrame at: 'source' at: 'path'.
	line := topFrame at: 'line'.
	frameId := topFrame at: 'id'.
	depth := aStackTrace at: 'totalFrames'.

	names := assignmentCollector getAssignmentNameFromLine:
		         (fileLineCache getLine: line from: path asFileReference).

	top := pendingAssignmentsStack isEmpty
		       ifTrue: [ nil ]
		       ifFalse: [ pendingAssignmentsStack top ].

	names do: [ :name |
			(top isNil or: [ top targetExpression ~= name ]) ifTrue: [
					| pendingAssignment split |
					pendingAssignment := PendingAssignment new
						                     oldValue:
							                     (self hashExpression: name in: frameId);
						                     stackDepth: depth;
						                     lineNumber: line;
						                     filepath: path.

					split := name splitOnFirst: $..

					split second isEmpty
						ifFalse: [
								| key this objExpr |
								self flag: 'move this to clientDAP backend'.
								this := split first.
								key := clientDap backend generateKey.
								clientDap backend store: key forExpression: this.
								objExpr := clientDap backend readExpressionForKey: key.

								pendingAssignment
									object: (self hashExpression: this in: frameId);
									targetExpression: split last;
									objectExpression: objExpr ]
						ifTrue: [
								pendingAssignment
									object: nil;
									targetExpression: name;
									objectExpression: '' ].

					pendingAssignmentsStack push: pendingAssignment ] ]
]

{ #category : 'helpers' }
StackCollector >> shouldSkipFrameBody: currentFrameBody [

	| path |
	path := (currentFrameBody at: 'stackFrames') first
		        at: 'source'
		        at: 'path'.

	^ path includesSubstring: 'runpy.py'
]

{ #category : 'helpers' }
StackCollector >> transformVariables: aDictionary with: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	^ Dictionary new
		  at: 'name' put: (aDictionary at: 'name');
		  at: 'value'
		  put: (self hashVariable: aDictionary in: aReceiverFrameId);
		  yourself
]
