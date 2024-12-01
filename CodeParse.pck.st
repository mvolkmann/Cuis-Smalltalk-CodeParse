'From Cuis7.1 [latest update: #6876] on 1 December 2024 at 5:52:12 am'!
'Description '!
!provides: 'CodeParse' 1 1!
SystemOrganization addCategory: 'CodeParse'!


!classDefinition: #ParseTree category: 'CodeParse'!
Object subclass: #ParseTree
	instanceVariableNames: ''
	classVariableNames: 'IndentDict'
	poolDictionaries: ''
	category: 'CodeParse'!
!classDefinition: 'ParseTree class' category: 'CodeParse'!
ParseTree class
	instanceVariableNames: ''!

!classDefinition: #TypeCheck category: 'CodeParse'!
Object subclass: #TypeCheck
	instanceVariableNames: ''
	classVariableNames: 'Enabled'
	poolDictionaries: ''
	category: 'CodeParse'!
!classDefinition: 'TypeCheck class' category: 'CodeParse'!
TypeCheck class
	instanceVariableNames: ''!


!ParseTree class methodsFor: 'as yet unclassified' stamp: 'RMV 11/30/2024 16:37:16'!
indentDepth: aNumber
	^ IndentDict at: aNumber ifAbsentPut: [
		String new: aNumber * 4 withAll: Character space.
	]
! !

!ParseTree class methodsFor: 'as yet unclassified' stamp: 'RMV 11/30/2024 16:26:52'!
initialize
	IndentDict := Dictionary new.! !

!ParseTree class methodsFor: 'as yet unclassified' stamp: 'RMV 11/30/2024 09:14:37'!
printCode: aString
	| parseNode parser stream |

	parser := Parser new.
	parseNode := parser parse: aString class: ParseTree.

	"Generate indentation string based on the current level"
	"indentation := String new: indentLevel * 4 withAll: Character space."

	stream := WriteStream on: (String new: 300).
	parseNode printOn: stream depth: 0.
	stream contents print.! !

!TypeCheck class methodsFor: 'accessing' stamp: 'RMV 11/24/2024 18:21:02'!
disable
	Enabled := false.! !

!TypeCheck class methodsFor: 'accessing' stamp: 'RMV 11/24/2024 18:20:55'!
enable
	Enabled := true.! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/30/2024 16:26:27'!
initialize
	Enabled := false.! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/27/2024 20:08:25'!
parseDemo
	| code methodNode parser |
	
	code := '
	rectangleAreaWidth: widthNumber height: heightNumber
		"Answer the area of a rectangle."
		| area doubleHeight doubleWidth sum |

		"This demonstrates using backticks for a compile-time expression."
		sum := `2 + 3`.

		area := widthNumber * heightNumber.
		doubleWidth := self double: widthNumber.
		doubleHeight := self double: heightNumber.
		area := doubleWidth * doubleHeight * 2.
		^ area.
	'.
	parser := Parser new.
	methodNode := parser parse: code class: TypeCheck.
	Transcript clear.
	methodNode printTree.
	
! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/27/2024 12:18:39'!
printCodeNode: aParseNode indent: indentString
	| hasBlock nextIndent singleIndent |
	
	singleIndent := '    '.
	nextIndent := indentString, '    '.

	Transcript newLine.
	indentString, aParseNode class name :: print.
	

	aParseNode isMethodNode ifTrue: [
		Transcript show: indentString.
		aParseNode printSelectorAndArgumentsOn: Transcript.
		Transcript cr.
	] ifFalse: [
		indentString, aParseNode printSourceCode :: print.
	].

	"TODO: When the RHS of an assignment is a message send,
	how can you follow that parse tree?
	IT IS A MessageNode!!"
	aParseNode isAssignmentNode ifTrue: [
		| value |
		value := aParseNode value.
		value isMessageNode ifTrue: [
			self printCodeNode: value indent: nextIndent.

			"value receiver may be a LiteralVariableNode."
			Transcript show: nextIndent, 'receiver: '.
			value receiver printOn: Transcript.
			Transcript cr.

			"value selector may be a SpecialSelectorNode."
			Transcript show: nextIndent, 'selector: '.
			value selector printOn: Transcript indent: ''.
			Transcript cr.

			"value arguments is an Array."
			Transcript show: nextIndent, 'arguments '.
			value arguments printOn: Transcript.
			Transcript cr.
		] ifFalse: [
			indentString, 'value is a ', value class name :: print.
		].
	].

	hasBlock := aParseNode isBlockNode or: [aParseNode isMethodNode].
	hasBlock ifTrue: [
		aParseNode block statements do: [:statement |
			self printCodeNode: statement indent: nextIndent.
		]
	].
	
! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/25/2024 18:25:34'!
argNamesinReceiver: anObject selector: selectorSymbol
	"Answer an OrderedCollection of the argument names in a given method."
	| argNodes code implementor methodNode |
	
	implementor := anObject class lookupClassImplementingSelector: selectorSymbol.
	code := implementor sourceCodeAt: selectorSymbol.
	methodNode := Parser new parse: code class: implementor.
	argNodes := methodNode arguments.
	^ argNodes collect: [:node | node name].! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/25/2024 18:25:53'!
check
	"Raise error if any argument has the wrong type."
	| argNames argValues keywords receiver selector sender |
	
	Enabled ifFalse: [^self].

	sender := thisContext sender.
	receiver := thisContext sender receiver.
	selector := sender selector.
	keywords := selector keywords.
	argNames := self argNamesinReceiver: receiver selector: selector.
	argValues := sender arguments.
		
	argNames withIndexDo: [:argName :index |
		| class className |
		className := argName substringFromFirstUpper asSymbol.
		class := self classFromName: className.
		class ifNotNil: [
			| argValue keyword |
			keyword := keywords at: index.
			argValue := argValues at: index.
			argValue isKindOf: class :: ifFalse: [
				| template values |
				template := '{1} {2} must be kind of {3} but was {4}'.
				values := {keyword. argName. className. argValue class name}.
				Error signal: (template format: values).
			].
		]
	].! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/28/2024 09:54:18'!
classFromName: nameSymbol
	"Answer class object corresponding to a class name string."
	| class globalDict |

	globalDict := Smalltalk globals at: #Smalltalk.
	class := globalDict at: nameSymbol ifAbsent: nil.
	
	class ifNil: [
		| className |
		className := nameSymbol caseOf: {
			[#Block] -> [#BlockClosure].
			[#Coll] -> [#Collection].
			[#Dict] -> [#Dictionary].
			[#IdDict] -> [#IdentityDictionary].
			[#Ord] -> [#OrderedCollection].
			[#Seq] -> [#SequenceableCollection].
			[#Sorted] -> [#SortedCollection].
		} otherwise: nil.
		className ifNotNil: [
			class := globalDict at: className ifAbsent: nil.
		]
	].
		
	^class.! !

!Object methodsFor: '*CodeParse' stamp: 'RMV 11/25/2024 08:39:47'!
logAs: aString
	"Writes logging information about receiver to the Transcript."
	| message sender template |

	sender := thisContext sender.
	template := 'In {1}, {2} is a {3} = {4}'.
	message := template format: {sender. aString. self class name. self}.
	message print.! !

!Object methodsFor: '*CodeParse' stamp: 'RMV 11/21/2024 18:31:44'!
validateAssoc
	"Raise error if self is not an Association object."

	self isKindOf: Association ::
		ifFalse: [Error signal: 'requires Association object'].! !

!Object methodsFor: '*CodeParse' stamp: 'RMV 11/22/2024 18:53:57'!
validateAssocSeq
	"Raise error if self is not a SequenceableCollection of Association objects."

	self validateSeq.

	self allSatisfy: [:element | element isKindOf: Association] ::
		ifFalse: [Error signal: 'requires SequenceableCollection of Association objects'].! !

!Object methodsFor: '*CodeParse' stamp: 'RMV 11/22/2024 18:54:27'!
validateSeq
	"Raise error if anObject is not a SequenceableCollection."

	self isCollection and: [self isSequenceable] ::
		ifFalse: [Error signal: 'requires SequenceableCollection like Array'].! !

!ParseNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 16:10:49'!
printOn: aStream depth: aNumber
	self halt.
	aStream
		nextPutAll: (ParseTree indentDepth: aNumber);
		nextPutAll: self class name;
		newLine.! !

!AssignmentNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 18:32:58'!
printOn: aStream depth: aNumber
	| indent indentNext |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.
	
	aStream nextPutAll: indent; nextPutAll: 'assignment:'; newLine.
	aStream nextPutAll: indentNext; nextPutAll: 'variable: '; nextPutAll: variable name; newLine.
	aStream nextPutAll: indentNext; nextPutAll: 'value:'; newLine.
	value printOn: aStream depth: aNumber + 2.! !

!BacktickNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 16:12:07'!
printOn: aStream depth: aNumber
	aStream
		nextPutAll: (ParseTree indentDepth: aNumber);
		nextPutAll: 'backtick: `';
		nextPutAll: sourceCode;
		nextPut: $`;
		newLine.! !

!BraceNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 18:40:30'!
printOn: aStream depth: aNumber
	| indent |

	indent := ParseTree indentDepth: aNumber.
	aStream
		nextPutAll: indent;
		nextPutAll: 'dynamic array: ';
		newLine.
	elements ifNotEmpty: [
		elements do: [:element |
			element printOn: aStream depth: aNumber + 1.
		].
	].! !

!BlockNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 15:58:17'!
printOn: aStream depth: aNumber
	| indent indentNext |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.

	aStream nextPutAll: indent; nextPutAll: 'block:'; newLine.

	arguments ifNotEmpty: [
		aStream nextPutAll: indentNext; nextPutAll: 'arguments: | '.
		arguments do: [:argument |
			aStream nextPutAll: argument name; space.
		].
		aStream nextPutAll: '|'; newLine.
	].
	
	"Output comments."
	"Output temporaries."

	statements do: [:statement | statement printOn: aStream depth: aNumber + 1].
! !

!MethodNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 18:24:23'!
printOn: aStream depth: aNumber
	| indent indentNext |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.

	aStream nextPutAll: indent; nextPutAll: 'method: '.
	self printSelectorAndArgumentsOn: aStream.
	aStream newLine.
	
	comment ifNotNil: [
		comment do: [:commentLine |
			aStream
				nextPutAll: indentNext;
				nextPutAll: 'comment: "';
				nextPutAll: commentLine;
				nextPut: $";
				newLine.
		].
	].

	self temporaries ifNotEmpty: [
		aStream nextPutAll: indentNext; nextPutAll: 'temporary variables: | '.
		self temporaries do: [:temporary |
			aStream nextPutAll: temporary key; space.
		].
		aStream nextPut: $|; newLine.
	].
	
	block statements do: [:statement |
		statement printOn: aStream depth: aNumber + 1
	].
! !

!LeafNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 18:43:27'!
printOn: aStream depth: aNumber
	| indent text |

	indent := ParseTree indentDepth: aNumber.
	text := key isString ifTrue: ['''', key, ''''] ifFalse: [key asString].
	
	aStream
		nextPutAll: indent;
		nextPutAll: 'leaf: ';
		nextPutAll: text;
		newLine.! !

!VariableNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 18:43:17'!
printOn: aStream depth: aNumber
	aStream
		nextPutAll: (ParseTree indentDepth: aNumber);
		nextPutAll: 'variable: ';
		nextPutAll: name;
		newLine.! !

!TempVariableNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 16:17:24'!
printOn: aStream depth: aNumber
	| indent |

	indent := ParseTree indentDepth: aNumber.
	aStream
		nextPutAll: indent;
		nextPutAll: 'temporary variable: ';
		nextPutAll: self name;
		newLine.! !

!MessageNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 19:12:53'!
printOn: aStream depth: aNumber
	| indent indentNext type |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.
	receiver class name logAs: 'receiver class name'.
	
	type := precedence caseOf: { [1] -> ['unary']. [2] -> ['binary']. [3] -> ['keyword'] }.
	aStream nextPutAll: indent; nextPutAll: type, ' message:'; newLine.
	
	aStream nextPutAll: indentNext; nextPutAll: 'receiver:'.
	receiver isMessageNode
		ifTrue: [
			aStream newLine.
			receiver printOn: aStream depth: aNumber + 2
		]
		ifFalse: [
			aStream space; nextPutAll: receiver name; newLine.
		].

	aStream nextPutAll: indentNext; nextPutAll: 'selector: #'; nextPutAll: selector key; newLine.
	
	arguments ifNotEmpty: [
		aStream nextPutAll: indentNext; nextPutAll: 'arguments:'; newLine.
		arguments do: [:argument |
			argument printOn: aStream depth: aNumber + 2.
		]
	].! !

!ReturnNode methodsFor: '*CodeParse' stamp: 'RMV 11/30/2024 19:08:43'!
printOn: aStream depth: aNumber
	aStream
		nextPutAll: (ParseTree indentDepth: aNumber);
		nextPutAll: 'return:';
		newLine.
	expr printOn: aStream depth: aNumber + 1.
! !

!Behavior methodsFor: '*CodeParse' stamp: 'RMV 11/23/2024 21:21:57'!
lookupClassImplementingSelector: selectorSymbol
	"Look up the given selector in my methodDictionary.
	Return the class that implements it if found.
	Otherwise chase the superclass chain and try again.
	Return nil if no implementing class is found."
	| class |

	class := self.
	[class == nil] whileFalse: [
		class includesSelector: selectorSymbol :: ifTrue: [^ class].
		class := class superclass
	].
	^ nil! !
ParseTree initialize!
TypeCheck initialize!
