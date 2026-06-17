"
I represent the Java language within the trace collection framework.

I implement the language-specific services required by SupportedLanguage
by:
- launching a java debug adapter,
- creating a DAP client configured with the Java backend,
- preparing the execution of a Java project for trace collection.

This class is used by TraceCollector to obtain
execution traces from java programs.
"
Class {
	#name : 'JavaLanguage',
	#superclass : 'SupportedLanguage',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'private - actions' }
JavaLanguage class >> classPathFrom: aPath [

    | pathString index |

    pathString := aPath asString.

    index := pathString indexOfSubCollection: '/target/classes'.

    ^ pathString copyFrom: 1 to: index + '/target/classes' size - 1
]

{ #category : 'actions' }
JavaLanguage class >> createClientFor: aPath atPort: aNumber [

	| mainClass classPath sourcePath |
	mainClass := self mainClassFrom: aPath.
	classPath := self classPathFrom: aPath.
	sourcePath := self sourcePathFrom: aPath.

	^ DAPClientBuilder newSindarinClient
		  port: aNumber;
		  adapterID: 'java';
		  functionBreakpoint: 'example.Main#main';
		  arguments: {
				  ('console' -> 'internalConsole').
				  ('mainClass' -> 'example.Main').
				  ('classPaths'
				   ->
					   { '/Users/flavienvolant/Documents/sindarin-dap/java/target/classes' }).
				  ('sourcePaths'
				   ->
					   { '/Users/flavienvolant/Documents/sindarin-dap/java/src/main/java' }).
				  ('justMyCode' -> true) } asDictionary;
		  backend: DAPBackendJava new;
		  startClientSession
]

{ #category : 'actions' }
JavaLanguage class >> launchAdapterAtPort: aNumber [

	AdapterLauncher launchJavaAdapterAtPort: aNumber
]

{ #category : 'private - actions' }
JavaLanguage class >> mainClassFrom: aPath [

	| prefix start relative |
	prefix := '/target/classes/'.

	start := aPath indexOfSubCollection: prefix.

	start = 0 ifTrue: [ self error: 'Path is not inside target/classes' ].

	relative := aPath copyFrom: start + prefix size to: aPath size.

	relative := relative copyUpToLast: $..

	^ relative copyReplaceAll: '/' with: '.'
]

{ #category : 'private - actions' }
JavaLanguage class >> sourcePathFrom: aPath [

    | base |

    base := aPath asString
        copyFrom: 1
        to: (aPath asString indexOfSubCollection: '/target/classes') - 1.

    ^ base , '/src/main/java'
]
