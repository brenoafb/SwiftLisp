import Foundation

var env = defaultEnvironment

print(">", separator: "", terminator: " ")
while let line = readLine() {
  if let expression = Expr(parse: line) {
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
