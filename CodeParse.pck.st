'From Cuis7.1 [latest update: #6876] on 5 December 2024 at 7:01:09 pm'!
'Description '!
!provides: 'CodeParse' 1 20!
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

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 10:03:50'!
example3
	"Demonstrate a message that takes a block."
	| code |

	code := 'doubleSumNumbers: aSeq
	"Answer double the sum of numbers in aSeq"
	| sum |
	sum := aSeq fold: [:acc :n | acc + n].
	^sum * 2'.

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

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 09:35:41'!
example5
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

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 09:36:57'!
example6
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

!ParseTree class methodsFor: 'examples' stamp: 'RMV 12/1/2024 09:36:06'!
example7
	"Demonstrate an assignment with multiple binary messages."
	| code |

	code := 'b := 1. c := 2. a := b + c'.

	ParseTree initialize.
	Transcript clear.
	ParseTree printNonMethodCode: code.
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

!ParseTree class methodsFor: 'private' stamp: 'RMV 12/1/2024 08:58:34'!
convertToReadableString: aString [
    | result |
    result := ''.
    aString withIndexDo: [:char :index |
        (char isUppercase and: [index > 1]) ifTrue: [
            result := result, ' '.
        ].
        result := result, char asLowercase.
    ].
    ^result.
]! !

!ParseTree class methodsFor: 'private' stamp: 'RMV 12/5/2024 19:00:11'!
indentDepth: aNumber
	^ self memoize: [
		String new: aNumber * 4 withAll: Character space.
	]! !

!ParseTree class methodsFor: 'private' stamp: 'RMV 12/1/2024 09:04:25'!
wordsFromCamelCase: aString
	| stream |
	stream := WriteStream on: (String new: 100).
	stream nextPut: aString first asLowercase.
	aString allButFirst do: [:char |
		char isUppercase ifTrue: [ stream space ].
		stream nextPut: char asLowercase.
	].
	^stream contents.! !

!Object methodsFor: '*CodeParse' stamp: 'RMV 12/5/2024 15:24:49'!
memoize: aBlock
	| cache cacheKey sender valueKey |
	
	sender := thisContext sender.
	
	"Smalltalk is a SystemDictionary which is an IdentityDictionary.
	That is why cacheKey must be a Symbol."
	cacheKey := ('cache-', sender name) asSymbol.

	cache := Smalltalk at: cacheKey ifAbsentPut: [ IdentityDictionary new ].
	valueKey := thisContext name, sender arguments asString :: asSymbol.

	^ cache at: valueKey ifAbsentPut: [ aBlock value ].! !

!String methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 09:05:26'!
wordsFromCamelCase
	| stream |
	stream := WriteStream on: (String new: 100).
	stream nextPut: self first asLowercase.
	self allButFirst do: [:char |
		char isUppercase ifTrue: [ stream space ].
		stream nextPut: char asLowercase.
	].
	^stream contents.! !

!ParseNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 10:51:05'!
printOn: aStream depth: aNumber
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

!BlockNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 10:49:48'!
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

!MethodNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 09:49:37'!
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

!LeafNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 09:09:55'!
printOn: aStream depth: aNumber
	| label text |
	
	"Using allButLast: 4 removes the word 'Node' from the end of the class name."
	label := self class name allButLast: 4 :: wordsFromCamelCase.

	text := key isString
		ifTrue: ['String ''', key, '''']
		ifFalse: [
			key isCharacter
				ifTrue: ['Character $', key asString]
				ifFalse: [key asString]
		].
	
	aStream
		nextPutAll: (ParseTree indentDepth: aNumber);
		nextPutAll: label;
		space;
		nextPutAll: text;
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

!MessageNode methodsFor: '*CodeParse' stamp: 'RMV 12/1/2024 10:07:18'!
printOn: aStream depth: aNumber
	| indent indentNext name suffix type |

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
				name := receiver isLiteralNode ifTrue: [receiver key asString] ifFalse: [receiver name].
				aStream space; nextPutAll: name; newLine.
			].
	].

	aStream nextPutAll: indentNext; nextPutAll: 'selector: #'; nextPutAll: selector key; newLine.
	
	arguments ifNotEmpty: [
		suffix := arguments size = 1 ifTrue: [''] ifFalse: ['s'].
		aStream nextPutAll: indentNext; nextPutAll: 'argument', suffix, ':'; newLine.
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
