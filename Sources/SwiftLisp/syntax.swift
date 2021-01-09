import Foundation

enum Expr {
  case atom (String)
  case list ([Expr])
  case nilexpr
}

extension Expr : CustomStringConvertible {
  var description: String {
    switch self {
    case let .atom(str):
      return str
    case let .list(elements):
      var strings: [String] = []
      for element in elements {
        strings.append(element.description)
      }
      return "[\(strings)]"
    case .nilexpr:
      return "NIL"
    }
    
  }
}