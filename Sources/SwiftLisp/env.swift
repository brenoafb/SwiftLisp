import Foundation
#if os(Linux)
import FoundationNetworking
#endif

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
  "println": .native(printlnFunc),
  "print": .native(printFunc),
  "request": .native(request),
  "json-to-assoc-list": .native(jsonToAssocList),
]])

let jsonToAssocList: NativeFunction = { (args) -> Expr? in
  guard args.count == 1 else {
    return nil
  }

  guard case let .string(json) = args.first as? Expr else {
    return nil
  }

  let data = Data(json.utf8)

  guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
    print("Error converting data to dictionary")
    return nil
  }

  guard let assocList = dictToAssocList(dict) else {
    return nil
  }

  return assocList
}

let request: NativeFunction = { (args) -> Expr? in
  guard args.count == 1 else {
    return nil
  }

  var sem = DispatchSemaphore(value: 0)

  guard case let .string(urlstr) = args.first as? Expr else {
    return nil
  }

  guard let url = URL(string: urlstr) else {
    return nil
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
    return .list([])
  }

  if let result = result {
    return .string(result)
  }

  return .list([])
}

let printlnFunc: NativeFunction = { (args) -> Expr? in
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

let printFunc: NativeFunction = { (args) -> Expr? in
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
