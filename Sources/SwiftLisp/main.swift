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

//func readInput(_ input: String = "") -> String {
//  var currInput = input
//  guard let line = readLine() else {
//    return ""
//  }
//
//  currInput += line
//  switch checkParens(currInput) {
//  case .incomplete:
//    print("~", separator: "", terminator: " ")
//    return readInput(currInput)
//  case .invalid:
//    print("Invalid input")
//    return readInput()
//  case .valid:
//    return currInput
//  }
//}
//
//func repl() {
//  print(">", separator: "", terminator: " ")
//  let input = readInput()
//  if let exprs = Parser.parse(input) {
//    for expr in exprs {
//      if let result = expr.eval(env) {
//        print("> \(result)")
//      } else {
//        print("ERROR")
//      }
//    }
//  } else {
//    print("Parsing error")
//  }
//  repl()
//}

// repl()

func readInput() -> String {
  var input = ""
  while let line = readLine(strippingNewline: true) {
    input += line
  }
  return input
}

func execFile(filename: String, env: Environment) -> Bool {
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    print("Error reading file \(filename)")
    return false
  }
  
  guard let exprs = Parser.parse(contents) else {
    print("Error parsing file \(filename)")
    return false
  }
  
  for expr in exprs {
    print(expr)
    guard let result = expr.eval(env) else {
      print("Error evaluatng expression in file \(filename)")
      return false
    }
    
    print(result)
  }
  
  return true
}

if CommandLine.argc > 1 {
  for argument in CommandLine.arguments[1...] {
    let _ = execFile(filename: argument, env: env)
  }
}

//let input = readInput()
//if let exprs = Parser.parse(input) {
//  for expr in exprs {
//    print(expr)
//  }
//  for expr in exprs {
//    if let result = expr.eval(env) {
//      print(result)
//    } else {
//      print("Eval error")
//    }
//  }
//  
//} else {
//  print("Parse error")
//}
