"
I am collecting the execution traces from an executing programme
https://github.com/RemiDufloer/Trace-Model-Design
"
Class {
	#name : 'DAPTraceCollector',
	#superclass : 'Object',
	#instVars : [
		'clientDap',
		'id',
		'fileLineCache',
		'pendingAssignmentsStack',
		'supportedLanguage',
		'projectPath'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'initialization' }
DAPTraceCollector class >> collectStackFrom: aDAPClient for: aSupportedLanguage project: aPath [
	"Collect and return the execution trace from aDAPClient for aSupportedLanguage."

	| collector |
	collector := self new
		             clientDap: aDAPClient;
		             supportedLanguage: aSupportedLanguage;
		             projectPath: aPath.

	^ collector getExecutionTraces
]

{ #category : 'initialization' }
DAPTraceCollector class >> collectStackWithoutAssignmentsFrom: aDAPClient for: aSupportedLanguage project: aPath [
	"Collect and return the execution trace, without assignments, from aDAPClient for aSupportedLanguage."

	| collector |
	collector := self new
		             clientDap: aDAPClient;
		             supportedLanguage: aSupportedLanguage;
		             projectPath: aPath.

	^ collector getExecutionTracesWithoutAssignments
]

{ #category : 'helpers' }
DAPTraceCollector >> addAssignmentTraceFrom: currentFrameBody to: traces [

	| assignment |
	assignment := self popPendingAssignment: currentFrameBody.

	assignment ifNotNil: [ traces add: assignment ].

	self pushPendingAssignment: currentFrameBody
]

{ #category : 'helpers' }
DAPTraceCollector >> addCallTraceTo: traces depth: aNumber [

	traces addAll: (self currentCallTracesAtDepth: aNumber)
]

{ #category : 'helpers' }
DAPTraceCollector >> argumentsForFrame: aReceiverFrame [

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
DAPTraceCollector >> clientDap [

	^ clientDap
]

{ #category : 'accessing' }
DAPTraceCollector >> clientDap: aDAPClient [

	clientDap := aDAPClient
]

{ #category : 'helpers' }
DAPTraceCollector >> currentCallTracesAtDepth: aNumber [

	| frames senderFrame receiverFrame arguments |
	frames := clientDap stackFrames: clientDap mainThreadId.
	senderFrame := frames second.
	receiverFrame := frames first.

	arguments := self argumentsForFrame: receiverFrame.
	
	^ {
		  (self
			   getMessageFrom: receiverFrame
			   and: senderFrame
			   withArguments: arguments
			   atDepth: aNumber).
		  (self
			   getMethodFrom: receiverFrame
			   and: senderFrame
			   atDepth: aNumber) }
]

{ #category : 'helpers' }
DAPTraceCollector >> executedCodeForFrame: aFrame [

	^ {
		  ('file' -> (self formatPath: (aFrame at: 'source' at: 'path'))).
		  ('line' -> (aFrame at: 'line')) } asDictionary
]

{ #category : 'helpers' }
DAPTraceCollector >> formatPath: aString [
	"Answer aString as path relative to the receiver's projectPath."

	^ (aString asPath relativeToPath: projectPath) fullName
]

{ #category : 'accessing' }
DAPTraceCollector >> getExecutionTraces [
	"Return the execution trace from the dap client connected to a debugger"

	| traces |
	traces := OrderedCollection new.

	self initializeExecutionTracing.

	clientDap
		stepUntil: [ false ]
		do: [ self processCurrentStepInto: traces ].

	^ traces
]

{ #category : 'accessing' }
DAPTraceCollector >> getExecutionTracesWithoutAssignments [
	"Return the execution trace, without the assignments, from the dap client connected to a debugger"

	| traces |
	traces := OrderedCollection new.

	self initializeExecutionTracing.

	clientDap
		stepUntil: [ false ]
		do: [ self processCurrentWithoutAssignmentStepInto: traces ].

	^ traces
]

{ #category : 'helpers' }
DAPTraceCollector >> getMessageFrom: aReceiverFrame and: aSenderFrame withArguments: aCollectionOfVariables atDepth: aNumber [
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
		  at: 'depth' put: aNumber;
		  yourself
]

{ #category : 'helpers' }
DAPTraceCollector >> getMethodFrom: aReceiverFrame and: aSenderFrame atDepth: aNumber [
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
		  at: 'depth' put: aNumber;
		  yourself
]

{ #category : 'helpers' }
DAPTraceCollector >> hashExpression: aString in: aFrameId [
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
DAPTraceCollector >> hashVariable: aDictionary in: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	aDictionary ifNil: [ ^ nil ].

	^ Dictionary new
		  at: 'class'
		  put: (aDictionary at: 'type' ifAbsent: 'Class Unknown');
		  at: 'hash' put: ((clientDap
				    evaluate:
					    (clientDap backend hashExpressionFor:
							     (aDictionary at: 'evaluateName'))
				    frameId: aReceiverFrameId
				    onErrorDo: [
						    Dictionary new
							    at: 'result' put: 'ERROR';
							    yourself ]) at: 'result');
		  yourself
]

{ #category : 'accessing' }
DAPTraceCollector >> id [
	"Returns the current unique identifier and increments it for the next use."

	| result |
	result := id.
	id := id + 1.
	^ result
]

{ #category : 'initialization' }
DAPTraceCollector >> initialize [

	super initialize.

	fileLineCache := FileLineCache new.
	pendingAssignmentsStack := Stack new
]

{ #category : 'helpers' }
DAPTraceCollector >> initializeExecutionTracing [

	clientDap initializeDapRegistry.
	clientDap stackFrames: clientDap mainThreadId. "Need one stacktrace request for clientDap hasEnteredNewCall"
	id := 1
]

{ #category : 'helpers' }
DAPTraceCollector >> popPendingAssignment: aStackTrace [
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
				              ('file'
				               -> (self formatPath: topPendingAssignment filepath)).
				              ('line' -> topPendingAssignment lineNumber) }
				              asDictionary;
		              at: 'depth' put: topPendingAssignment stackDepth;
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
DAPTraceCollector >> processCurrentStepInto: traces [
	"Process the current step-into event and record call and
	assignment traces."

	| hasEnteredNewCall currentFrameBody |

	hasEnteredNewCall := clientDap hasEnteredNewCall.
	currentFrameBody := clientDap currentFrameBody.

	(self shouldSkipFrameBody: currentFrameBody)
		ifTrue: [ clientDap stepOut ]
		ifFalse: [
				hasEnteredNewCall ifTrue: [
						self
							addCallTraceTo: traces
							depth: (currentFrameBody at: 'totalFrames') ].
				self addAssignmentTraceFrom: currentFrameBody to: traces ]
]

{ #category : 'helpers' }
DAPTraceCollector >> processCurrentWithoutAssignmentStepInto: traces [
	"Process the current step-into event and record call traces only, ignoring assignment traces."

	| hasEnteredNewCall currentFrameBody |
	hasEnteredNewCall := clientDap hasEnteredNewCall.
	currentFrameBody := clientDap currentFrameBody.

	(self shouldSkipFrameBody: currentFrameBody)
		ifTrue: [ clientDap stepOut ]
		ifFalse: [
				hasEnteredNewCall ifTrue: [
						self
							addCallTraceTo: traces
							depth: (currentFrameBody at: 'totalFrames') ] ]
]

{ #category : 'accessing' }
DAPTraceCollector >> projectPath: aPath [

	projectPath := aPath asPath
]

{ #category : 'helpers' }
DAPTraceCollector >> pushPendingAssignment: aStackTrace [
	"Push a PendingAssignment if the top of aStackTrace is an assignments.
	aStackTrace is the body of a StackTraceResponse"

	| topFrame path line frameId names depth top |
	topFrame := (aStackTrace at: 'stackFrames') first.
	path := topFrame at: 'source' at: 'path'.
	line := topFrame at: 'line'.
	frameId := topFrame at: 'id'.
	depth := aStackTrace at: 'totalFrames'.

	names := AssignmentCollector new
		         getAssignmentNameFromLine:
		         (fileLineCache getLine: line from: path asFileReference)
		         for: supportedLanguage.

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
DAPTraceCollector >> shouldSkipFrameBody: currentFrameBody [
	"Answer true if the current frame should be ignored when collecting traces."

	| currentFrame path |
	currentFrame := (currentFrameBody at: 'stackFrames') first.

	path := currentFrame at: 'source' at: 'path' ifAbsent: [ ^ true ].

	^ supportedLanguage shouldSkipForPath: path
]

{ #category : 'accessing' }
DAPTraceCollector >> supportedLanguage: aSupportedLanguage [

	supportedLanguage := aSupportedLanguage
]

{ #category : 'helpers' }
DAPTraceCollector >> transformVariables: aDictionary with: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	^ Dictionary new
		  at: 'name' put: (aDictionary at: 'name');
		  at: 'value'
		  put: (self hashVariable: aDictionary in: aReceiverFrameId);
		  yourself
]
