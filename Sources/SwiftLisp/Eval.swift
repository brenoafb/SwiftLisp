import Foundation

protocol Evaluatable {
  func eval(_ env: Environment) throws -> Expr
}

public enum EvalError: Error {
  case invalidFunctionCall
  case unknownPrimitive(String)
  case wrongArgumentCount(String, Int, Int) // function, expected, actual
  case wrongArgumentType(String, String, String) // function, expected, actual
  case invalidArgument(String) // function
  case insufficientArguments(String, Int, Int) // function, minumum, actual
  case expectedPair(String) // function
  case malformedExpression
  case unknownSymbol(String)
  case nativeFunctionError(String, String) // function, description
}

extension Expr: Evaluatable {

  public func eval(_ env: Environment) throws -> Expr {
    switch self {
    case let .list(exprs):
      return try Expr.evalList(exprs, env: env)
    case let .atom(x):
      guard let result = env.lookup(x) else {
        throw EvalError.unknownSymbol(x)
      }
      return result
    case let .quote(x):
      return x
    default:
      return self
    }
  }

  static private func evalList(_ exprs: [Expr], env: Environment) throws -> Expr {
    if exprs.isEmpty {
      return Expr.list([])
    }

    if exprs[0].isPrimitive {
      return try evalPrimitive(exprs, env)
    } else if Expr.list(exprs).isLambda {
      // a lambda evaluates to itself
      return .list(exprs)
    } else if exprs[0].isLambda {
      // lambda application
      let function = exprs[0]
      if let arguments = getArguments(exprs, env: env) {
       return try apply(function: function, arguments: arguments, env: env)
      } else {
        throw EvalError.malformedExpression
      }
    } else {
      // function application
      if let function = getFunctionBody(exprs, env: env),
         let arguments = getArguments(exprs, env: env)
      {
        return try apply(function: function, arguments: arguments, env: env)
      } else {
        throw EvalError.malformedExpression
      }
    }
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
    return sequenceArray(Array(exprs.dropFirst()).map { try? $0.eval(env) })
  }

  static func apply(function: Expr, arguments: [Expr], env: Environment) throws -> Expr {
    if case let .native(f) = function {
      // call native function
      let argArray: [Any] = arguments
      let result = try f(argArray)
      return result
    } else {
      // lambda or lisp function application
      guard let argNames = function.getArgNames() else {
        throw EvalError.malformedExpression
      }

      let newFrame: [String:Expr] = Dictionary<String, Expr>(uniqueKeysWithValues: zip(argNames, arguments))
      guard let functionBody = function.getBody() else {
        throw EvalError.malformedExpression
      }

      env.pushFrame(newFrame)
      do {
        let result = try functionBody.eval(env)
        env.popFrame()
        return result
      } catch let error {
        env.popFrame()
        throw error
      }
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

  static private func evalPrimitive(_ exprs: [Expr], _ env: Environment) throws -> Expr {
    guard case let .atom(name) = exprs.first else {
      throw EvalError.invalidFunctionCall
    }

    guard let function = primitives[name] else {
      throw EvalError.unknownPrimitive(name)
    }

    let args = Array(exprs.dropFirst())

    return try function(args, env)
  }

}
