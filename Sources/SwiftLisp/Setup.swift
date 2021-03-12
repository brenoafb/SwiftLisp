//
//  Setup.swift
//  
//
//  Created by Breno on 12/03/21.
//

import Foundation

enum ExecutionError: Error {
  case fileReadError(String)
}

func loadBaseFiles(baseDir: String = "base") throws -> Environment {
  let baseFiles = ["base", "stdlib", "arithmetic"]
    .map {
      Bundle.module.url(forResource: "\(baseDir)/\($0)", withExtension: "lisp")!
    }
  let env = defaultEnvironment
  for file in baseFiles {
    let filename = file.path
    try execFile(filename: filename, env: env, options: [])
  }
  return env
}

func execFile(filename: String,
              env: Environment,
              options: [ExecOptions] = [.printResult]) throws {
  
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    throw ExecutionError.fileReadError(filename)
  }
  
  let exprs = try Parser.parse(contents)
  
  for expr in exprs {
    if (options.contains(.printParse)) {
      print(expr)
    }
    
    let result = try expr.eval(env)
    
    if options.contains(.printResult) {
      print(result)
    }
  }
}
