import Foundation

var env = defaultEnvironment

enum InputValidation {
  case valid
  case incomplete
  case invalid
}

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
