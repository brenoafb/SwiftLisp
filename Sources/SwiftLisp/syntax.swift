import Foundation

typealias NativeFunction = ([Any]) throws -> Expr

protocol Typeable {
  var type: String { get }
}

indirect enum Expr {
  case atom(String)
  case int(Int)
  case float(Double)
  case list([Expr])
  case quote(Expr)
  case native(NativeFunction)
  case string(String)
  case nilexpr
}

extension Expr : Typeable {
  var type: String {
    switch self {
    case .atom:
      return "atom"
    case .int:
      return "int"
    case .float:
      return "float"
    case .list:
      return "list"
    case .quote:
      return "quote"
    case .string:
      return "string"
    case .native:
      return "native"
    case .nilexpr:
      return "nil"
    }
  }
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
    case let .quote(x):
      return "'\(x.description)"
    case let .string(x):
      return "\"\(x)\""
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
    case let .quote(x):
      if case let .quote(y) = rhs {
        return x == y
      }
    case let .string(x):
      if case let .string(y) = rhs {
        return x == y
      }
    case .native:
      return false
    }
    return false
  }
}

