'From Cuis7.1 [latest update: #6876] on 1 December 2024 at 8:39:43 am'!
'Description '!
!provides: 'CodeParse' 1 12!
SystemOrganization addCategory: #CodeParse!


!classDefinition: #ParseTree category: #CodeParse!
Object subclass: #ParseTree
	instanceVariableNames: ''
	classVariableNames: 'IndentDict'
	poolDictionaries: ''
	category: 'CodeParse'!
!classDefinition: 'ParseTree class' category: #CodeParse!
ParseTree class
	instanceVariableNames: ''!


!ParseTree class methodsFor: 'class initialization' stamp: 'RMV 11/30/2024 16:26:52'!
initialize
	IndentDict := Dictionary new.! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:10:28'!
example1
	| code |

	code := 'sumNumber: n1 and: n2
	"Answer sum of n1 and n2."
	^ n1 + n2'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printMethodCode: code.
! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:10:33'!
example2
	"Demonstrate all three message types."
	| code |

	code := 'demo
	| interval n |
	n := 19.
	n print.
	n := n * 2.
	interval := 1 to: 10 by: 2.
	interval print.'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printMethodCode: code.
! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:10:38'!
example3
	"Demonstrate a message that takes a block."
	| code |

	code := 'sumNumber: aSeq
	"Answer sum of numbers in aSeq."
	| sum |
	sum := aSeq fold: [:acc :n | acc + n].
	sum := sum + 1.
	^sum.'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printMethodCode: code.
! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:10:46'!
example4
	"Demonstrate an assignment with multiple binary messages."
	| code |

	code := 'rectangleAreaWidth: widthNumber height: heightNumber
	"Answer the area of a rectangle."
	| area doubleHeight doubleWidth sum |

	"This demonstrates using backticks for a compile-time expression."
	sum := `2 + 3`.

	area := widthNumber * heightNumber.
	doubleWidth := self double: widthNumber.
	doubleHeight := self double: heightNumber.
	area := doubleWidth * doubleHeight * 2.
	^ area.'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printMethodCode: code.
! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:11:27'!
example5
	"Demonstrate an assignment with multiple binary messages."
	| code |

	code := '| a b c |
	b := 1.
	c := 2.
	a := b + c'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printNonMethodCode: code.
! !

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 08:27:46'!
example6
	"Demonstrate a cascade."
	| code |

	code := 'demoStream: aStream
	aStream
		nextPutAll: ''Hello'';
		nextPut: $,;
		nextPutAll: ''World!!'';
		newLine
	'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printMethodCode: code.
! !

!ParseTree class methodsFor: 'printing' stamp: 'RMV 12/1/2024 06:58:33'!
printCodeBasic: aString
	"Demonstrate printing a parse tree only using provided classes.
	Do not add indentation to indicate the depth of each node in the parse tree.
	Check for specific ParseNode subclasses
	in order to print information specific to that class
	(as is done above for the `MethodNode` class)."
	| enumerator parseNode parser stream |

	parser := Parser new.
	parseNode := parser parse: aString class: ParseTree.
	stream := WriteStream on: (String new: 300).
	enumerator := ParseNodeEnumerator ofBlock: [:node |
		stream nextPutAll: node class name; nextPutAll: ': '.
		node isMethodNode
			ifTrue: [ node printSelectorAndArgumentsOn: stream ]
			ifFalse: [ stream nextPutAll: node printSourceCode ].
		stream newLine.
	].
	parseNode accept: enumerator.
	stream contents print.! !

!ParseTree class methodsFor: 'printing' stamp: 'RMV 12/1/2024 08:08:32'!
printMethodCode: aString
	"Print the parse tree for a String that contains a method definition to the Transcript."
	| parseNode parser stream |

	parser := Parser new.
	parseNode := parser parse: aString class: ParseTree.
	stream := WriteStream on: (String new: 300).
	parseNode printOn: stream depth: 0.
	stream contents print.! !

!ParseTree class methodsFor: 'printing' stamp: 'RMV 12/1/2024 08:10:03'!
printNonMethodCode: aString
	"Print the parse tree for a String that contains code that
	does not begin with a method header to the Transcript."
	| parseNode parser stream |

	parser := Parser new.
	parseNode := parser parse: aString class: ParseTree noPattern: true.
	stream := WriteStream on: (String new: 300).
	parseNode printOn: stream depth: 0.
	stream contents print.! !

!ParseTree class methodsFor: 'private' stamp: 'RMV 12/1/2024 07:15:47'!
indentDepth: aNumber
	IndentDict ifNil: [ Error signal: 'ParseTree class not initialized' ].
	^ IndentDict at: aNumber ifAbsentPut: [
		String new: aNumber * 4 withAll: Character space.
	]
! !

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

!CascadeNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 08:31:29'!
printOn: aStream depth: aNumber
	| indent indentNext |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.

	aStream nextPutAll: indent; nextPutAll: 'cascade:'; newLine.

	aStream nextPutAll: indentNext; nextPutAll: 'receiver:'.
	receiver isMessageNode
		ifTrue: [
			aStream newLine.
			receiver printOn: aStream depth: aNumber + 2
		]
		ifFalse: [
			aStream space; nextPutAll: receiver name; newLine.
		].

	messages do: [:message |
		message printOn: aStream depth: aNumber + 1
	].
! !

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

!MethodNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 07:13:03'!
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

!LeafNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 08:39:30'!
printOn: aStream depth: aNumber
	| indent text |

	indent := ParseTree indentDepth: aNumber.
	text := key isString
		ifTrue: ['String ''', key, '''']
		ifFalse: [
			key isCharacter
				ifTrue: ['Character $', key asString]
				ifFalse: [key asString]
		].
	
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

!MessageNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 08:34:48'!
printOn: aStream depth: aNumber
	| indent indentNext type |

	indent := ParseTree indentDepth: aNumber.
	indentNext := ParseTree indentDepth: aNumber + 1.
	
	type := precedence caseOf: { [1] -> ['unary']. [2] -> ['binary']. [3] -> ['keyword'] }.
	aStream nextPutAll: indent; nextPutAll: type, ' message:'; newLine.
	
	"receiver is nil in cascade messages"
	receiver ifNotNil: [
		aStream nextPutAll: indentNext; nextPutAll: 'receiver:'.
		receiver isMessageNode
			ifTrue: [
				aStream newLine.
				receiver printOn: aStream depth: aNumber + 2
			]
			ifFalse: [
				aStream space; nextPutAll: receiver name; newLine.
			].
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
