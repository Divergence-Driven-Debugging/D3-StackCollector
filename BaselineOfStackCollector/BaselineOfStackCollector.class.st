Class {
	#name : 'BaselineOfStackCollector',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfStackCollector',
	#package : 'BaselineOfStackCollector'
}

{ #category : 'baselines' }
BaselineOfStackCollector >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'StackCollector';
				package: 'StackCollector-Tests' ]
]
