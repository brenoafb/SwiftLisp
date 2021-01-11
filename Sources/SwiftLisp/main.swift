import Foundation

var env = defaultEnvironment

enum InputValidation {
  case valid
  case incomplete
  case invalid
}

func checkParens(_ str: String) -> InputValidation {
  var count = 0
  for char in str {
    switch char {
    case "(":
      count += 1
    case ")":
      if count == 0 {
        return .invalid
      }
      count -= 1
    default:
      break
    }
    
  }
  return count == 0 ? .valid : .incomplete
}

func readInput(_ input: String = "") -> String {
  var currInput = input
  guard let line = readLine() else {
    return ""
  }
  
  currInput += line
  switch checkParens(currInput) {
  case .incomplete:
    print("~", separator: "", terminator: " ")
    return readInput(currInput)
  case .invalid:
    print("Invalid input")
    return readInput()
  case .valid:
    return currInput
  }
}

func repl() {
  print(">", separator: "", terminator: " ")
  let input = readInput()
  if let expression = Expr(parse: input) {
    print("\(expression)")
    if let result = expression.eval(env) {
      print("> \(result)")
    } else {
      print("ERROR")
    }
  } else {
    print("Parsing error")
  }
  repl()
}

repl()
