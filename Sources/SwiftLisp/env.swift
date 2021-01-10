//
//  File.swift
//  
//
//  Created by Breno on 10/01/21.
//

import Foundation

typealias EnvFrame = [String:Expr]
typealias Environment = [EnvFrame]

var defaultEnvironment: Environment = [[
  "+": .native(binaryIntOperation({ $0 + $1 })),
  "*": .native(binaryIntOperation({ $0 * $1 })),
  "-": .native(binaryIntOperation({ $0 - $1 })),
  "/": .native(binaryIntOperation({ $0 / $1 })),
  "x": .int(3232),
  "y": .int(6464),
  "f": Expr(parse: "(lambda (x y) (eq x y))")!
]]

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

extension Environment {
  func lookup(_ s: String) -> Expr? {
    for frame in self {
      if let x = frame[s] {
        return x
      }
    }
    return nil
  }
  
  func pushFrame(_ newFrame: EnvFrame) -> Environment {
    var env = self
    env.insert(newFrame, at: 0)
    return env
  }
}
