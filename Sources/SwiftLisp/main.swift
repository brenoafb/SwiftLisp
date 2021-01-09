import Foundation

let str = "(hello (world))"
if let expression = Expr(parse: str) {
  print(expression)
}