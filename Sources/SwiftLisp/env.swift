//
//  File.swift
//
//
//  Created by Breno on 10/01/21.
//

import Foundation

typealias EnvFrame = [String:Expr]

class Environment {

  private var stack: [EnvFrame]

  init() {
    stack = []
  }

  init(_ stack: [EnvFrame]) {
    self.stack = stack
    self.stack.insert([:], at: 0)
  }

  func lookup(_ s: String) -> Expr? {
    for frame in stack {
      if let x = frame[s] {
        return x
      }
    }
    return nil
  }

  func pushFrame(_ newFrame: EnvFrame) {
    stack.insert(newFrame, at: 0)
  }

  func popFrame() {
    let _ = stack.removeFirst()
  }

  func addBinding(key: String, value: Expr) {
    stack[0][key] = value
  }
}

var defaultEnvironment = Environment([[
  "+.i": .native(binaryIntOperation({ $0 + $1 })),
  "*.i": .native(binaryIntOperation({ $0 * $1 })),
  "-.i": .native(binaryIntOperation({ $0 - $1 })),
  "/.i": .native(binaryIntOperation({ $0 / $1 })),
  "<.i": .native(binaryIntComparison({ $0 < $1 })),
  ">.i": .native(binaryIntComparison({ $0 > $1 })),
  ">=.i": .native(binaryIntComparison({ $0 >= $1 })),
  "<=.i": .native(binaryIntComparison({ $0 <= $1 })),
  "!=.i": .native(binaryIntComparison({ $0 != $1 })),
  "+.f": .native(binaryFloatOperation({ $0 + $1 })),
  "*.f": .native(binaryFloatOperation({ $0 * $1 })),
  "-.f": .native(binaryFloatOperation({ $0 - $1 })),
  "/.f": .native(binaryFloatOperation({ $0 / $1 })),
  "<.f": .native(binaryFloatComparison({ $0 < $1 })),
  ">.f": .native(binaryFloatComparison({ $0 > $1 })),
  ">=.f": .native(binaryFloatComparison({ $0 >= $1 })),
  "<=.f": .native(binaryFloatComparison({ $0 <= $1 })),
  "!=.f": .native(binaryFloatComparison({ $0 != $1 })),
]])

func binaryIntComparison(_ comp: @escaping (Int, Int) -> Bool) -> NativeFunction {
  let function: NativeFunction = { [f = comp] (args) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    if case let .int(x) = args[0] as? Expr {
      if case let .int(y) = args[1] as? Expr {
        return f(x, y) ? .atom("t") : .list([])
      }
    }

    return nil
  }

  return function
}

func binaryIntOperation(_ binop: @escaping (Int, Int) -> Int) -> NativeFunction {
  let function: NativeFunction = { [f = binop] (args) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    if case let .int(x) = args[0] as? Expr {
      if case let .int(y) = args[1] as? Expr {
        return .int(f(x, y))
      }
    }

    return nil
  }

  return function
}

func binaryFloatComparison(_ comp: @escaping (Double, Double) -> Bool) -> NativeFunction {
  let function: NativeFunction = { [f = comp] (args) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    if case let .float(x) = args[0] as? Expr {
      if case let .float(y) = args[1] as? Expr {
        return f(x, y) ? .atom("t") : .list([])
      }
    }

    return nil
  }

  return function
}


func binaryFloatOperation(_ binop: @escaping (Double, Double) -> Double) -> NativeFunction {
  let function: NativeFunction = { [f = binop] (args) -> Expr? in
    guard args.count == 2 else {
      return nil
    }

    if case let .float(x) = args[0] as? Expr {
      if case let .float(y) = args[1] as? Expr {
        return .float(f(x, y))
      }
    }

    return nil
  }

  return function
}
