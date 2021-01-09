import Foundation

typealias Environment = [String:Expr]

protocol Evaluatable {
  func eval(_ env: Environment) -> Expr?
}

extension Expr: Evaluatable {
  
  func eval(_ env: Environment) -> Expr? {
    switch self {
    case let .list(exprs):
      return evalList(exprs, env: env)
    case let .atom(x):
      return env[x]
    default:
      return .list([])
    }
  }
  
  private func evalList(_ exprs: [Expr], env: Environment) -> Expr? {
    guard let first = exprs.first else {
      return Expr.list([])
    }
    
    if isPrimitive(first) {
      return evalPrimitive(exprs, env)
    } else {
      // TODO
    }
    
    return nil
  }
  
  private func isPrimitive(_ expr: Expr) -> Bool {
    let primitives = [
      "quote",
      "atom",
      "eq",
      "car",
      "cdr",
      "cons",
      "cond"
    ]
    
    switch expr {
    case let .atom(x):
      return primitives.contains(x)
    default:
      return false
    }
  }
  
  private func evalPrimitive(_ exprs: [Expr], _ env: Environment) -> Expr? {
    guard let first = exprs.first else {
      return Expr.list([])
    }
    
    switch first {
    case .atom("quote"):
      return evalQuote(exprs, env: env)
    case .atom("atom"):
      return evalAtomP(exprs, env: env)
    case .atom("eq"):
      return evalEq(exprs, env: env)
    case .atom("car"):
      return evalCar(exprs, env: env)
    case .atom("cdr"):
      return evalCdr(exprs, env: env)
    case .atom("cons"):
      return evalCons(exprs, env: env)
    case .atom("cond"):
      return evalCond(exprs, env: env)
    default:
      return nil
    }
  }
  
  private func evalQuote(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 2 else {
      return nil
    }
    return exprs[safeIndex: 1]
  }
  
  private func evalAtomP(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 2 else {
      return nil
    }
    switch exprs[1] {
    case .atom:
      return .atom("t")
    default:
      return .list([])
    }
  }

  private func evalEq(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 3 else {
      return nil
    }
    return exprs[1] == exprs[2] ? .atom("t") : .list([])
  }
  
  private func evalCar(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 2 else {
      return nil
    }
    switch exprs[1] {
    case .list:
      switch exprs[1].eval(env) {
      case let .list(xs):
        return xs[0]
      default:
        return nil
      }
      
    default:
      return nil
    }
  }
  
  private func evalCdr(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 2 else {
      return nil
    }
    switch exprs[1] {
    case .list:
      switch exprs[1].eval(env) {
      case let .list(xs):
        return .list(Array(xs.dropFirst()))
      default:
        return nil
      }
    default:
      return nil
    }
  }
  
  private func evalCons(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count == 3 else {
      return nil
    }
    
    guard let x = exprs[1].eval(env) else {
      return nil
    }
    print("exprs[2]: \(exprs[2])")
    switch exprs[2].eval(env) {
    case let .list(xs):
      print(xs)
      var xxs = [x]
      xxs.append(contentsOf: xs)
      return .list(xxs)
    default:
      return nil
    }
  }
  
  private func evalCond(_ exprs: [Expr], env: Environment) -> Expr? {
    guard exprs.count > 1 else {
      return nil
    }
    
    for comp in exprs {
      switch comp {
      case let .list(xs):
        guard xs.count == 2 else { return nil }
        switch xs.first?.eval(env) {
        case nil:
          return nil
        case .atom("t"):
          return xs[1]
        default:
          break
        }
      default:
        return nil
      }
    }
    return .list([])
  }
}

extension Array {
  public subscript(safeIndex i: Int) -> Element? {
    return i >= 0 && i < self.count ? self[i] : nil
  }
}
