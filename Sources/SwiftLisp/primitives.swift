import Foundation

typealias Primitive = ([Expr], Environment) throws -> Expr

let primitives: [String:Primitive] = [
  
  "quote": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 1 else {
      throw EvalError.wrongArgumentCount("quote", 1, args.count)
    }
    return args[0]
  }
  ,
  "atom": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 1 else {
      throw EvalError.wrongArgumentCount("atom", 1, args.count)
    }
    
    let evald = try args[0].eval(env)
    
    switch evald {
    case .atom:
      return .atom("t")
    default:
      return .list([])
    }
  },
  
  "eq": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("eq", 2, args.count)
    }

    let evald0 = try args[0].eval(env)
    let evald1 = try args[1].eval(env)

    return evald0 == evald1 ? .atom("t") : .list([])
  },
  
  "car": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 1 else {
      throw EvalError.wrongArgumentCount("car", 1, args.count)
    }
    
    let evald = try args[0].eval(env)
    
    switch evald {
    case let .list(xs):
      guard let car = xs.first else {
        throw EvalError.invalidArgument("car")
      }
      return car
    default:
      throw EvalError.wrongArgumentType("car", "list", evald.type)
    }
  },
  
  "cdr": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 1 else {
      throw EvalError.wrongArgumentCount("cdr", 1, args.count)
    }
    
    let evald = try args[0].eval(env)
    
    switch evald {
    case let .list(xs):
      switch xs.count {
      case 0:
        throw EvalError.invalidArgument("cdr")
      default:
        return .list(Array(xs.dropFirst()))
      }
    default:
      throw EvalError.wrongArgumentType("cdr", "list", evald.type)
    }
  },
  
  "cons": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("cons", 2, args.count)
    }

    let evald0 = try args[0].eval(env)
    let evald1 = try args[1].eval(env)
    
    guard case let .list(xs) = evald1 else {
      throw EvalError.wrongArgumentType("cons", "list", evald1.type)
    }

    return .list([evald0] + xs)
  },
  
  "cond": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count > 0 else {
      throw EvalError.insufficientArguments("cond", 1, args.count)
    }

    for comp in args {
      switch comp {
      case let .list(xs):
        guard xs.count == 2 else { throw EvalError.expectedPair("cond") }
        
        let evald = try xs.first?.eval(env)
        
        switch evald {
        case .atom("t"):
          let result = try xs[1].eval(env)
          return result
        default:
          break
        }
      default:
        throw EvalError.wrongArgumentType("cond", "list", comp.type) // not really descriptive since cond is a special form
      }
    }
    return .list([])
  },
  
  "list": {(args: [Expr], env: Environment) throws -> Expr in
    guard let x = sequenceArray(args.map { try? $0.eval(env) }) else {
      throw EvalError.invalidArgument("list") // TODO make more descriptive
    }

    return .list(x)
  },
  
  "define": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("define", 2, args.count)
    }

    guard case let .atom(key) = args[0] else {
      throw EvalError.wrongArgumentType("define", "atom", args[0].type)
    }

    let expr = args[1]
    if expr.isLambda {
      env.addBinding(key: key, value: expr)
      return .atom("t")
    }

    let value = try expr.eval(env)

    env.addBinding(key: key, value: value)

    return .atom("t")
  },
  
  "type": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 1 else {
      throw EvalError.wrongArgumentCount("type", 1, args.count)
    }

    let value = try args[0].eval(env)

    return .atom(value.type)
  },
  
  "seq": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count > 0 else {
      return .list([])
    }

    guard let results = sequenceArray(Array(args).map { try? $0.eval(env) }) else {
      throw EvalError.invalidArgument("seq")
    }

    guard let last = results.last else {
      throw EvalError.invalidArgument("seq")
    }
    
    return last
  },
  
  "foldr": {(args: [Expr], env: Environment) throws -> Expr in
    guard args.count == 3 else {
      throw EvalError.wrongArgumentCount("foldr", 3, args.count)
    }

    let function = try args[0].eval(env)
    let initialValue = try args[1].eval(env)
    let list = try args[2].eval(env)
    
    guard case let .list(xs) = list else {
      throw EvalError.wrongArgumentType("foldr", "list", list.type)
    }

    var acc: Expr = initialValue

    for x in xs.reversed() {
      acc = try Expr.apply(function: function, arguments: [x, acc], env: env)
    }
    
    return acc
  }
]
