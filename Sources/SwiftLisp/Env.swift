import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

typealias EnvFrame = [String:Expr]

public class Environment {

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
  "println": .native(printlnFunc),
  "print": .native(printFunc),
  "request": .native(request),
  "json-to-assoc-list": .native(jsonToAssocList),
]])

let jsonToAssocList: NativeFunction = { (args) throws -> Expr in
  guard args.count == 1 else {
    throw EvalError.wrongArgumentCount("jsonToAssocList", 1, args.count)
  }
  
  guard let expr = args.first as? Expr else {
    throw EvalError.nativeFunctionError("jsonToAssocList", "Error converting argument to expr")
  }

  guard case let .string(json) = expr else {
    throw EvalError.wrongArgumentType("jsonToAssocList", "string", expr.type)
  }

  let data = Data(json.utf8)

  guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
    throw EvalError.nativeFunctionError("jsonToAssocList", "Error converting data to dictionary")
  }

  guard let assocList = dictToAssocList(dict) else {
    throw EvalError.nativeFunctionError("jsonToAssocList", "Error converting dictionary to assoc list")
  }

  return assocList
}

let request: NativeFunction = { (args) throws -> Expr in
  guard args.count == 1 else {
    throw EvalError.wrongArgumentCount("request", 1, args.count)
  }

  var sem = DispatchSemaphore(value: 0)

  guard let expr = args.first as? Expr else {
    throw EvalError.nativeFunctionError("request", "Error converting argument to expr")
  }
  
  guard case let .string(urlstr) = expr else {
    throw EvalError.wrongArgumentType("request", "string", expr.type)
  }

  guard let url = URL(string: urlstr) else {
    throw EvalError.nativeFunctionError("request", "Error creating URL")
  }

  print("request url: \(url)")

  var error: Error? = nil
  var result: String? = nil
  let session = URLSession(configuration: .default)
  let task = session.dataTask(with: url) { (d, r, e) in
    // print("error: \(String(describing: error))")
    // print("response: \(String(describing: response))")
    if let e = e {
      error = e
      return
    }

    guard let d = d else {
      print("Error getting data")
      return
    }

    guard let s = String(data: d, encoding: .utf8) else {
      print("Error converting data to string")
      return
    }

    result = s

    sem.signal()
  }

  task.resume()
  sem.wait()

  if let error = error {
    return .list([.atom("error"), .string(String(describing:error))])
  }

  if let result = result {
    return .string(result)
  }

  return .list([])
}

let printlnFunc: NativeFunction = { (args) throws -> Expr in
  for arg in args {
    if case let .string(s) = arg as? Expr {
      print(s, terminator: "")
    } else {
      print(arg, terminator: "")
    }
  }
  print()
  return .atom("t")
}

let printFunc: NativeFunction = { (args) throws -> Expr in
  for arg in args {
    if case let .string(s) = arg as? Expr {
      print(s, terminator: "")
    } else {
      print(arg, terminator: "")
    }
  }
  return .atom("t")
}

func binaryIntComparison(_ comp: @escaping (Int, Int) -> Bool) -> NativeFunction {
  let function: NativeFunction = { [f = comp] (args) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("binaryIntComparison", 2, args.count)
    }
    
    guard let expr0 = args[0] as? Expr,
          let expr1 = args[1] as? Expr
    else {
      throw EvalError.nativeFunctionError("binaryIntComparison", "Error converting argument to expr")
    }
    
    guard case let .int(x) = expr0,
          case let .int(y) = expr1
    else {
      throw EvalError.wrongArgumentType("binaryIntComparison", "int/int", "\(expr0.type)/\(expr1.type)")
    }
    
    return f(x, y) ? .atom("t") : .list([])
  }

  return function
}

func binaryIntOperation(_ binop: @escaping (Int, Int) -> Int) -> NativeFunction {
  let function: NativeFunction = { [f = binop] (args) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("binaryIntOperation", 2, args.count)
    }
    
    guard let expr0 = args[0] as? Expr,
          let expr1 = args[1] as? Expr
    else {
      throw EvalError.nativeFunctionError("binaryIntOperation", "Error converting argument to expr")
    }
    
    guard case let .int(x) = expr0,
          case let .int(y) = expr1
    else {
      throw EvalError.wrongArgumentType("binaryIntOperation", "int/int", "\(expr0.type)/\(expr1.type)")
    }

    return .int(f(x, y))
  }

  return function
}

func binaryFloatComparison(_ comp: @escaping (Double, Double) -> Bool) -> NativeFunction {
  let function: NativeFunction = { [f = comp] (args) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("binaryFloatComparison", 2, args.count)
    }
    
    guard let expr0 = args[0] as? Expr,
          let expr1 = args[1] as? Expr
    else {
      throw EvalError.nativeFunctionError("binaryFloatComparison", "Error converting argument to expr")
    }
    
    guard case let .float(x) = expr0,
          case let .float(y) = expr1
    else {
      throw EvalError.wrongArgumentType("binaryFloatComparison", "float/float", "\(expr0.type)/\(expr1.type)")
    }
    
    return f(x, y) ? .atom("t") : .list([])
  }

  return function
}


func binaryFloatOperation(_ binop: @escaping (Double, Double) -> Double) -> NativeFunction {
  let function: NativeFunction = { [f = binop] (args) throws -> Expr in
    guard args.count == 2 else {
      throw EvalError.wrongArgumentCount("binaryFloatOperation", 2, args.count)
    }
    
    guard let expr0 = args[0] as? Expr,
          let expr1 = args[1] as? Expr
    else {
      throw EvalError.nativeFunctionError("binaryFloatOperation", "Error converting argument to expr")
    }
    
    guard case let .float(x) = expr0,
          case let .float(y) = expr1
    else {
      throw EvalError.wrongArgumentType("binaryFloatOperation", "float/float", "\(expr0.type)/\(expr1.type)")
    }
  
    return .float(f(x, y))
  }

  return function
}
