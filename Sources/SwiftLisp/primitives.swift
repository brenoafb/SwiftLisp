import Foundation

typealias Primitive = ([Expr], Environment) -> Expr?

let primitives: [String:Primitive] = [
  "quote": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 1 else {
      return nil
    }
    return args[0]
  },
  "atom": {(args: [Expr], env: Environment) -> Expr? in
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
  },
  "eq": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    guard let arg0 = args[0].eval(env),
          let arg1 = args[1].eval(env) else {
      return nil
    }

    return arg0 == arg1 ? .atom("t") : .list([])
  },
  "car": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 1 else {
      return nil
    }
    switch args[0].eval(env) {
    case let .list(xs):
      return xs.first
    default:
      return nil
    }
  },
  "cdr": {(args: [Expr], env: Environment) -> Expr? in
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
  },
  "cons": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    guard let x = args[0].eval(env),
          case let .list(xs) = args[1].eval(env) else {
      return nil
    }

    return .list([x] + xs)
  },
  "cond": {(args: [Expr], env: Environment) -> Expr? in
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
  },
  "list": {(args: [Expr], env: Environment) -> Expr? in
    guard let x = sequenceArray(args.map { $0.eval(env) }) else {
      return nil
    }

    return .list(x)
  },
  "define": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    guard case let .atom(key) = args[0] else {
      return nil
    }

    let expr = args[1]
    if expr.isLambda {
      env.addBinding(key: key, value: expr)
      return .atom("t")
    }

    guard let value = expr.eval(env) else {
      return .list([])
    }

    env.addBinding(key: key, value: value)

    return .atom("t")
  },
  "type": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 1 else {
      return nil
    }

    guard let value = args[0].eval(env) else {
      return .list([])
    }

    switch value {
    case .atom:
      return .atom("atom")
    case .int:
      return .atom("int")
    case .float:
      return .atom("float")
    case .list:
      return .atom("list")
    case .quote:
      return .atom("quote")
    case .string:
      return .atom("string")
    case .native:
      return .atom("native")
    default:
      return .list([])
    }
  },
  "seq": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count > 0 else {
      return .list([])
    }

    guard let results = sequenceArray(Array(args).map { $0.eval(env) }) else {
      return nil
    }

    return results.last
  },
  "foldr": {(args: [Expr], env: Environment) -> Expr? in
    guard args.count == 3 else {
      return .list([])
    }

    guard let function = args[0].eval(env),
          let initialValue = args[1].eval(env),
          case let .list(xs) = args[2].eval(env)
          else {
    return nil
    }

    var acc: Expr = initialValue

    for x in xs.reversed() {
      guard let result = Expr.apply(function: function, arguments: [x, acc], env: env) else {
        return nil
      }
      acc = result
    }
    return acc
  }
]
