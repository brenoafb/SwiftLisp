# SwiftLisp

Small Lisp interpreter written in Swift.

## Building and Running

This project uses the Swift Package Manager.

To build.

```bash
$ swift build
```

You can then run by providing a script as input.

```bash
$ swift run slisp examples/script.lisp
```

This project also implements a SwiftPM library that can be used in projects.

```swift
import SwiftLisp

...

func execute() {
  let input = readInput()
  do {
    let env = try loadBaseFiles
    let ast = try Parser.parse()
    for expr in ast {
      let result = try expr.eval(env)
      print(result)
    }
  } catch let error {
    print(error)
  }
}


```

## Examples

Check the `examples` directory for more examples.

- Function definition

```lisp
(define fib
  (lambda (x)
    (cond ((eq x 0) 0)
          ((eq x 1) 1)
          ('t
           (+ (fib (- x 1))
              (fib (- x 2)))))))
```

- HTTP request

```lisp
(define url "https://jsonplaceholder.typicode.com/todos/1")

(request url)
```

- Convert JSON to associative list

```lisp
(define url "https://jsonplaceholder.typicode.com/todos/1")

(define json (request url))

(define dict (json-to-assoc-list json))

dict

> [["id" 1] ["completed" 0] ["userId" 1] ["title" "delectus aut autem"]]
```

## References

- [Roots of Lisp - Paul Graham](http://www.paulgraham.com/rootsoflisp.html)
