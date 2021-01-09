import Foundation

print(">", separator: "", terminator: " ")
while let line = readLine() {
  if let expression = Expr(parse: line) {
    print(expression)
    let env: Environment = [:]
    if let result = expression.eval(env) {
      print("> \(result)")
    } else {
      print("ERROR")
    }
  } else {
    print("Parsing error")
  }
  print(">", separator: "", terminator: " ")
}
