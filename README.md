# CodeParse

This library adds the method `printOn:depth:` to the `ParseNode` class
and overrides it in many of its subclasses.
Those methods print an indented description of a parse tree
that is obtained by creating a `Parser` instance and sending it `#parse:class:`.

This library also adds the `ParseTree` class which has
the class methods `printMethodCode:` and `printNonMethodCode:`.
The `printMethodCode:` takes a string of Smalltalk code that defines a method.
The `printNonMethodCode:` takes a string of Smalltalk code
that does not begin with a method header (signature),
such as what might be used in a "Do it".

## Why is this useful?

- It helps in understanding how the Smalltalk compiler views code.
- It provides an example of working with `ParseNode` objects.
  Those can be used to transform Smalltalk code into different code,
  possibly in another programming language.

## Isn't there an easier, built-in way?

Well ... sort of. You could do something like the following
that uses the visitor pattern to visit each `ParseNode` instance.

```smalltalk

printCodeBasic: aString
    | enumerator parseNode parser stream |

    parser := Parser new.
    parseNode := parser parse: aString class: ParseTree.
    "Add `noPattern: true` above if aString does not define a method."

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

But this approach does not add indentation to
indicate the depth of each node in the parse tree.
It also requires testing for each `ParseNode` subclass
for which output should be specific to that class
(as is done above for the `MethodNode` class).

## Examples

Try evaluating `ParseTree example{n}` in a Workspace
where `{n}` is replaced by a number from 1 to 7.

`example2` parses the following code:

```smalltalk
demo
    | interval n |
    n := 19.
    n print.
    n := n * 2.
    interval := 1 to: 10 by: 2.
    interval print.
```

It produces the following output:

```text
method: demo
    temporary variables: | interval n |
    assignment:
        variable: n
        value:
            literal 19
    unary message:
        receiver: n
        selector: #print
    assignment:
        variable: n
        value:
            binary message:
                receiver: n
                selector: #*
                argument:
                    literal 2
    assignment:
        variable: interval
        value:
            keyword message:
                receiver: 1
                selector: #to:by:
                arguments:
                    literal 10
                    literal 2
    unary message:
        receiver: interval
        selector: #print
    return:
        variable String 'self'
```

## Compatibility with Other Smalltalks

This package is not compatible with Squeak Smalltalk
because it adds a method to the `BacktickNode` class
which is not provided in Squeak.

This package is not compatible with Pharo Smalltalk because
Pharo does not provide the `ParseNode` class or its many subclasses.
