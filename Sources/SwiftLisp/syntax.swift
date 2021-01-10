import Foundation

typealias NativeFunction = ([Any]) -> Expr?

enum Expr {
  case atom(String)
  case int(Int)
  case float(Double)
  case list([Expr])
  case native(NativeFunction)
  case nilexpr
}

extension Expr : CustomStringConvertible {
  var description: String {
    switch self {
    case let .atom(str):
      return str
    case let .int(x):
      return x.description
    case let .float(x):
      return x.description
    case let .list(elements):
      var strings: [String] = []
      for element in elements {
        strings.append(element.description)
      }
      let s = strings.reduce("") { (acc, x) in
        return acc.isEmpty ? x : acc + " " + x
      }
      return "[\(s)]"
    case .native:
      return "<native function>"
    case .nilexpr:
      return "NIL"
    }
    
  }
}

extension Expr : Equatable {
  static func == (lhs: Expr, rhs: Expr) -> Bool {
    switch lhs {
    case let .atom(x):
      if case let .atom(y) = rhs {
        return x == y
      }
    case let .int(x):
      if case let .int(y) = rhs {
        return x == y
      }
    case let .float(x):
      if case let .float(y) = rhs {
        return x == y
      }
    case let .list(xs):
      if case let .list(ys) = rhs {
        return xs.elementsEqual(ys)
      }
    case .nilexpr:
      if case .nilexpr = rhs {
        return true
      } else {
        return false
      }
    case .native:
      return false
    }
    return false
  }
}
