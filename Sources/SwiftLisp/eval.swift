import Foundation

protocol Evaluatable {
  func eval(_ env: Environment) -> Expr?
}

extension Expr: Evaluatable {

  func eval(_ env: Environment) -> Expr? {
    switch self {
    case let .list(exprs):
      return Expr.evalList(exprs, env: env)
    case let .atom(x):
      return env.lookup(x)
    case let .quote(x):
      return x
    default:
      return self
    }
  }

  static private func evalList(_ exprs: [Expr], env: Environment) -> Expr? {
    if exprs.isEmpty {
      return Expr.list([])
    }

    if exprs[0].isPrimitive {
      return evalPrimitive(exprs, env)
    } else if Expr.list(exprs).isLambda {
      // a lambda evaluates to itself
      return .list(exprs)
    } else if exprs[0].isLambda {
      // lambda application
      let function = exprs[0]
      if let arguments = getArguments(exprs, env: env) {
        return apply(function: function, arguments: arguments, env: env)
      }
    } else {
      // function application
      if let function = getFunctionBody(exprs, env: env),
         let arguments = getArguments(exprs, env: env)
      {
        return apply(function: function, arguments: arguments, env: env)
      }
    }

    return nil
  }

  static func getFunctionBody(_ exprs: [Expr], env: Environment) -> Expr? {
    guard let first = exprs.first else {
      return nil
    }
    switch first {
    case let .atom(name):
      return env.lookup(name)
    default:
      return nil
    }
  }

  static func getArguments(_ exprs: [Expr], env: Environment) -> [Expr]? {
    return sequenceArray(Array(exprs.dropFirst()).map { $0.eval(env) })
  }

  static func apply(function: Expr, arguments: [Expr], env: Environment) -> Expr? {
    if case let .native(f) = function {
      // call native function
      let argArray: [Any] = arguments
      return f(argArray)
    } else {
      // lambda or lisp function application
      guard let argNames = function.getArgNames() else {
        return nil
      }

      let newFrame: [String:Expr] = Dictionary<String, Expr>(uniqueKeysWithValues: zip(argNames, arguments))
      let functionBody = function.getBody()

      env.pushFrame(newFrame)
      guard let result = functionBody?.eval(env) else {
        env.popFrame()
        return nil
      }
      env.popFrame()
      return result
    }
  }

  func getBody() -> Expr? {
    guard isLambda,
          case let .list(xs) = self,
          xs.count == 3,
          case let .list(body) = xs[2]
    else {
      return nil
    }

    return .list(body)
  }

  func getArgNames() -> [String]? {
    guard isLambda,
          case let .list(xs) = self,
          xs.count == 3,
          case let .list(argList) = xs[1]
    else {
      return nil
    }

    return sequenceArray(argList.map {
      guard case let .atom(s) = $0 else {
        return nil
      }
      return s
    })
  }

  var isPrimitive: Bool {
    switch self {
    case let .atom(name):
      return Array(primitives.keys).contains(name)
    default:
      return false
    }
  }

  var isLambda: Bool {
    switch self {
    case let .list(exprs):
      guard let first = exprs.first else {
        return false
      }
      switch first {
      case .atom("lambda"):
        return exprs.count > 1
      default:
        return false
      }
    default:
      return false
    }
  }

  static private func evalPrimitive(_ exprs: [Expr], _ env: Environment) -> Expr? {
    guard case let .atom(name) = exprs.first else {
      return nil
    }

    guard let function = primitives[name] else {
      return nil
    }

    let args = Array(exprs.dropFirst())

    return function(args, env)
  }

}
