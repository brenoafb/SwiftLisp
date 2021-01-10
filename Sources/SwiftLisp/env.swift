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

    if let x = args[0] as? Int {
      if let y = args[1] as? Int {
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
    // TODO
    return []
  }
}
