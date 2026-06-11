"
I am a class made to launch scripts. These scripts run projects in different langages.
"
Class {
	#name : 'AdapterLauncher',
	#superclass : 'Object',
	#category : 'StackCollector',
	#package : 'StackCollector'
}

{ #category : 'api' }
AdapterLauncher class >> launchPythonAdapterAtPort: aNumber [
	"Launch the python adapter"

	OSPlatform current runCommand:
		'nohup .env/bin/python3 pharo-local/iceberg/Divergence-Driven-Debugging/D3-StackCollector/scripts/setup.py py '
		, aNumber asString , ' > /tmp/debugpy.log 2>&1 &'
]

{ #category : 'api' }
AdapterLauncher >> launchPythonAdapterAtPort: aNumber [
	"Launch the python adapter"

	^ self class launchPythonAdapterAtPort: aNumber
]
