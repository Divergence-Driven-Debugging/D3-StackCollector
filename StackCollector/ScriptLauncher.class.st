"
I am a class made to launch scripts. These scripts run projects in different langages.
"
Class {
	#name : 'ScriptLauncher',
	#superclass : 'Object',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'api' }
ScriptLauncher >> runPythonProject: aFileReference [

	OSPlatform current runCommand: 'python setup.py py ' , aFileReference
]
