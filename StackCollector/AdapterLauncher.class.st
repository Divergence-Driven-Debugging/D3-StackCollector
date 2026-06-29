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
AdapterLauncher class >> launchJSAdapterAtPort: aNumber onProject: aProjectPath [
	"Launch the java adapter"

	OSPlatform current runCommand:
		'nohup .env/bin/python3 pharo-local/iceberg/Divergence-Driven-Debugging/D3-StackCollector/scripts/setup.py js '
		, aNumber asString , ' ' , aProjectPath
		, ' > /tmp/debugpy.log 2>&1 &'
]

{ #category : 'api' }
AdapterLauncher class >> launchJavaAdapterAtPort: aNumber onProject: aProjectPath [
	"Launch the java adapter"

	OSPlatform current runCommand:
		'nohup .env/bin/python3 pharo-local/iceberg/Divergence-Driven-Debugging/D3-StackCollector/scripts/setup.py java '
		, aNumber asString , ' ' , aProjectPath
		, ' > /tmp/debugpy.log 2>&1 &'
]

{ #category : 'api' }
AdapterLauncher class >> launchPythonAdapterAtPort: aNumber onProject: aProjectPath [
	"Launch the python adapter"

	OSPlatform current runCommand:
		'nohup venv/bin/python3 pharo-local/iceberg/Divergence-Driven-Debugging/D3-StackCollector/scripts/setup.py py '
		, aNumber asString , ' ' , aProjectPath
		, ' > /tmp/debugpy.log 2>&1 &'
]
