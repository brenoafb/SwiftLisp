import Foundation

enum Expr : Equatable {
  case atom(String)
  case list([Expr])
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
      let s = strings.reduce("") { (acc, x) in
        return acc.isEmpty ? x : acc + " " + x
      }
      return "[\(s)]"
    case .nilexpr:
      return "NIL"
    }
    
  }
}

//extension Expr : Equatable {
//  
//}
