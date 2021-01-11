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
    case let .int(x):
      return .int(x)
    case let .float(x):
      return .float(x)
    case let .quote(x):
      return x
    default:
      return .list([])
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
        // print("lambda application:\(function), \(arguments)")
        return apply(function: function, arguments: arguments, env: env)
      }
    } else {
      // function application
      if let function = getFunctionBody(exprs, env: env),
         let arguments = getArguments(exprs, env: env)
      {
        // print("function application:\(function), \(arguments)")
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

  private var isPrimitive: Bool {
    let primitives = [
      "quote",
      "atom",
      "eq",
      "car",
      "cdr",
      "cons",
      "cond",
      "list",
      "define"
    ]
    
    switch self {
    case let .atom(name):
      return primitives.contains(name)
    default:
      return false
    }
  }

  private var isLambda: Bool {
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
    guard let first = exprs.first else {
      return Expr.list([])
    }
    
    let args = Array(exprs.dropFirst())
    switch first {
    case .atom("quote"):
      return evalQuote(args, env: env)
    case .atom("atom"):
      return evalAtomP(args, env: env)
    case .atom("eq"):
      return evalEq(args, env: env)
    case .atom("car"):
      return evalCar(args, env: env)
    case .atom("cdr"):
      return evalCdr(args, env: env)
    case .atom("cons"):
      return evalCons(args, env: env)
    case .atom("cond"):
      return evalCond(args, env: env)
    case .atom("list"):
      return evalListP(args, env: env)
    case .atom("define"):
      evalDefine(args, env: env)
      return .list([])
    default:
      return nil
    }
  }
  
  static private func evalQuote(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 1 else {
      return nil
    }
    return args[0]
  }
  
  static private func evalAtomP(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 1 else {
      return nil
    }
    switch args[0].eval(env) {
    case nil:
      return nil
    case .atom:
      return .atom("t")
    default:
      return .list([])
    }
  }

  static private func evalEq(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 2 else {
      return nil
    }
  
    guard let arg0 = args[0].eval(env),
          let arg1 = args[1].eval(env) else {
      return nil
    }
    
    return arg0 == arg1 ? .atom("t") : .list([])
  }
  
  static private func evalCar(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 1 else {
      return nil
    }
    switch args[0].eval(env) {
    case let .list(xs):
      return xs.first
    default:
      return nil
    }
  }
  
  static private func evalCdr(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 1 else {
      return nil
    }
    switch args[0].eval(env) {
    case let .list(xs):
      switch xs.count {
      case 0:
        return nil
      default:
        return .list(Array(xs.dropFirst()))
      }
    default:
      return nil
    }
  }
  
  static private func evalCons(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count == 2 else {
      return nil
    }
    
    guard let x = args[0].eval(env),
          case let .list(xs) = args[1].eval(env) else {
      return nil
    }
    
    return .list([x] + xs)
  }
  
  static private func evalCond(_ args: [Expr], env: Environment) -> Expr? {
    guard args.count > 0 else {
      return nil
    }
    
    for comp in args {
      switch comp {
      case let .list(xs):
        guard xs.count == 2 else { return nil }
        switch xs.first?.eval(env) {
        case nil:
          return nil
        case .atom("t"):
          return xs[1].eval(env)
        default:
          break
        }
      default:
        return nil
      }
    }
    return .list([])
  }
  
  static private func evalListP(_ args: [Expr], env: Environment) -> Expr? {
    guard let x = sequenceArray(args.map { $0.eval(env) }) else {
      return nil
    }
    
    return .list(x)
  }
  
  static private func evalDefine(_ args: [Expr], env: Environment) {
    guard args.count == 2 else {
      return
    }
    
    guard case let .atom(key) = args[0] else {
      return
    }
    
    let expr = args[1]
    if expr.isLambda {
      env.addBinding(key: key, value: expr)
      return
    }
    
    guard let value = expr.eval(env) else {
      return
    }
    
    env.addBinding(key: key, value: value)
  }
}

extension Array {
  public subscript(safeIndex i: Int) -> Element? {
    return i >= 0 && i < self.count ? self[i] : nil
  }
}

func sequenceArray<T>(_ xs: [T?]) -> [T]? {
  if xs.contains(where: { $0 == nil }) {
    return nil
  }
  return xs.map { $0! }
}
