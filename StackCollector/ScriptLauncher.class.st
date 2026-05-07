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
	"Runs the project, having as entry point aFileRefence, with the python adapter"

	OSPlatform current runCommand: 'venv/bin/python3 pharo-local/iceberg/Divergence-Driven-Debugging/StackCollector/scripts/setup.py py ' , aFileReference
]
