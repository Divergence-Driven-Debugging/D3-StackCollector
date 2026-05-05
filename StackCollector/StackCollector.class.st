"
I am collecting the execution traces from an executing programme
https://github.com/RemiDufloer/Trace-Model-Design
"
Class {
	#name : 'StackCollector',
	#superclass : 'Object',
	#instVars : [
		'clientDap',
		'id'
	],
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'as yet unclassified' }
StackCollector class >> collectStackFrom: aDAPClient [
	
	| collector |
	
	collector := self new clientDAP: aDAPClient.
	

]

{ #category : 'accessing' }
StackCollector >> clientDap [

	^ clientDap
]

{ #category : 'accessing' }
StackCollector >> clientDap: aDAPClient [

	clientDap := aDAPClient
]

{ #category : 'accessing' }
StackCollector >> getExecutionTraces [
	"Return the execution trace from the dap client connected to a debugger"

	| traces |
	traces := OrderedCollection new.

	clientDap stackFrames: clientDap mainThreadId.
	id := 1.

	clientDap stepUntil: [ false ] do: [
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
					traces add: method ] ].

	^ traces
]

{ #category : 'as yet unclassified' }
StackCollector >> getMessageFrom: aReceiverFrame and: aSenderFrame withArguments: aCollectionOfVariables [
	"Returns the dictionnay corresponding to the message call from a sender to a receiver"

	^ Dictionary
		  new;
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

{ #category : 'as yet unclassified' }
StackCollector >> getMethodFrom: aReceiverFrame [
	"Returns the dictionnay corresponding to the method from a receiver"

	^ Dictionary new
		  at: 'type' put: 'method';
		  at: 'id' put: id;
		  at: 'sender' put: nil;
		  at: 'receiver' put: nil;
		  at: 'method_name' put: (aReceiverFrame at: 'name');
		  at: 'executed_code' put: {
				  ('file' -> (aReceiverFrame at: 'source' at: 'path')).
				  ('line' -> (aReceiverFrame at: 'line')) } asDictionary;
		  yourself
]

{ #category : 'accessing' }
StackCollector >> id [

	| result |
	result := id.
	id := id + 1.
	^ result
]

{ #category : 'as yet unclassified' }
StackCollector >> transformVariables: aDictionary with: aReceiverFrameId [
	"Tranforms a dap Variable to the expected argument format"

	^ Dictionary new
		  at: 'name' put: (aDictionary at: 'name');
		  at: 'value' put: (Dictionary new
				   at: 'class' put: (aDictionary at: 'type');
				   at: 'hash' put: ((clientDap
						     evaluate: 'hash(' , (aDictionary at: 'evaluateName') , ')'
						     frameId: aReceiverFrameId) at: 'result');
				   yourself);
		  yourself
]
