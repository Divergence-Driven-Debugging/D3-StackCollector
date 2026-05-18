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
		'assignmentCollector'
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

{ #category : 'accessing' }
StackCollector >> clientDap [

	^ clientDap
]

{ #category : 'accessing' }
StackCollector >> clientDap: aDAPClient [

	clientDap := aDAPClient
]

{ #category : 'helpers' }
StackCollector >> getAssignmentFrom: aFrame [
	"Returns the dictionnay corresponding to the assignment from a frame nil if it's not an assignment"

	| path line frameId name old_value |
	path := aFrame at: 'source' at: 'path'.
	line := aFrame at: 'line'.
	frameId := aFrame at: 'id'.

	name := assignmentCollector getAssignmentNameFromLine:
		        (assignmentCollector getLine: line from: path).

	name ifNil: [ ^ nil ].



	old_value := (clientDap
		              evaluate: name
		              frameId: frameId
		              onErrorDo: [ { ('result' -> nil) } asDictionary ])
		             at: 'result'.

	^ Dictionary new
		  at: 'type' put: 'assignment';
		  at: 'id' put: self id;
		  at: 'object' put: nil;
		  at: 'variable' put: name;
		  at: 'old_value' put: old_value;
		  at: 'new_value' put: nil;
		  at: 'executed_code' put: {
				  ('file' -> path).
				  ('line' -> line) } asDictionary;
		  yourself
]

{ #category : 'accessing' }
StackCollector >> getExecutionTraces [
	"Return the execution trace from the dap client connected to a debugger"

	| traces |
	traces := OrderedCollection new.

	clientDap stackFrames: clientDap mainThreadId.
	id := 1.

	clientDap stepUntil: [ false ] do: [
			| assignment |
			clientDap hasEnteredNewCall ifTrue: [
					| message method frames senderFrame receiverFrame varRef vars arguments |
					frames := clientDap stackFrames: clientDap mainThreadId.
					senderFrame := frames second.
					receiverFrame := frames first.

					varRef := (clientDap scopesForFrame: (receiverFrame at: 'id'))
						          first at: 'variablesReference'. "local for python dap"
					vars := clientDap variablesForReference: varRef.
					arguments := vars collect: [ :dictionary |
						             self
							             transformVariables: dictionary
							             with: (receiverFrame at: 'id') ].

					message := self
						           getMessageFrom: receiverFrame
						           and: senderFrame
						           withArguments: arguments.

					method := self getMethodFrom: receiverFrame.

					traces add: message.
					traces add: method ].
			assignment := self getAssignmentFrom: clientDap currentFrame.
			assignment ifNotNil: [ traces add: assignment ] ].

	^ traces
]

{ #category : 'helpers' }
StackCollector >> getMessageFrom: aReceiverFrame and: aSenderFrame withArguments: aCollectionOfVariables [
	"Returns the dictionnay corresponding to the message call from a sender to a receiver"

	^ Dictionary new
		  at: 'type' put: 'message';
		  at: 'id' put: self id;
		  at: 'message_name' put: (aReceiverFrame at: 'name');
		  at: 'sender' put: nil;
		  at: 'receiver' put: nil;
		  at: 'args' put: aCollectionOfVariables;
		  at: 'executed_code' put: {
				  ('file' -> (aSenderFrame at: 'source' at: 'path')).
				  ('line' -> (aSenderFrame at: 'line')) } asDictionary;
		  yourself
]

{ #category : 'helpers' }
StackCollector >> getMethodFrom: aReceiverFrame [
	"Returns the dictionnay corresponding to the method from a receiver"

	^ Dictionary new
		  at: 'type' put: 'method';
		  at: 'id' put: self id;
		  at: 'sender' put: nil;
		  at: 'receiver' put: nil;
		  at: 'method_name' put: (aReceiverFrame at: 'name');
		  at: 'executed_code' put: {
				  ('file' -> (aReceiverFrame at: 'source' at: 'path')).
				  ('line' -> (aReceiverFrame at: 'line')) } asDictionary;
		  yourself
]

{ #category : 'helpers' }
StackCollector >> hashVariable: aDictionary with: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	^ Dictionary new
		  at: 'class' put: (aDictionary at: 'type');
		  at: 'hash' put: ((clientDap
				    evaluate: 'hash(' , (aDictionary at: 'evaluateName') , ')'
				    frameId: aReceiverFrameId) at: 'result');
		  yourself
]

{ #category : 'accessing' }
StackCollector >> id [

	| result |
	result := id.
	id := id + 1.
	^ result
]

{ #category : 'helpers' }
StackCollector >> initialize [

	| parser pythonLanguage |
	super initialize.

	assignmentCollector := AssignmentCollector new.
	parser := TSParser new.
	pythonLanguage := TSLanguage python.
	parser language: pythonLanguage.

	assignmentCollector parser: parser
]

{ #category : 'helpers' }
StackCollector >> transformVariables: aDictionary with: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	^ Dictionary new
		  at: 'name' put: (aDictionary at: 'name');
		  at: 'value'
		  put: (self hashVariable: aDictionary with: aReceiverFrameId);
		  yourself
]
