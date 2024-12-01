# CodeParse

This library adds the method `printOn:depth:` to the `ParseNode` class
and overrides it in many of its subclasses.
Those methods print an indented description of a parse tree
that is obtained by creating a `Parser` instance and sending it `#parse:class:`.

This library also adds the `ParseTree` class which has the class method `printCode:`.
The argument is a string of Smalltalk code.

## Why is this useful?

- It helps in understanding how the Smalltalk compiler views your code.
- It provides an example of working with `ParseNode` objects
  This can be used to transform Smalltalk code into different code,
  possibly in another programming language.

## Isn't there an easier, builtsin way

Well ... sort of. You could do something like this:

```smalltalk

printCodeBasic: aString
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
    stream contents print.
```

But this does not add indentation to indicate
the depth of each node in the parse tree.
It also requires testing for each `ParseNode` subclass
for which we want to output information specific to that class
(as is done above for the `MethodNode` class).

## Examples

Try entring the following:

```smalltalk
ParseTree example1
ParseTree example2
ParseTree example3
ParseTree example4
```
