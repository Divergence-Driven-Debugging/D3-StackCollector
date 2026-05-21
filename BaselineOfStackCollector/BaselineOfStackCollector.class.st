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
				baseline: 'TreeSitter'
				with: [
					spec repository: 'github://Evref-BL/Pharo-Tree-Sitter:main/src' ];
				baseline: 'PharoDAPClient'
				with: [
					spec repository: 'github://Pharo-XP-Tools/sindarin-dap:main' ];
				package: 'StackCollector' ]
]
