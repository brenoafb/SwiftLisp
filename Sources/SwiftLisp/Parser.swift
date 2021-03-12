import Foundation

enum ParseError: Error {
  case unmatchedOpenParen
  case unmatchedCloseParen
  case unclosedString
}

struct Parser {
  
  static private let specialSymbols: [String] = [
    "(", ")", "'", "\""
  ]
  
  static func parse(_ input: String) throws -> [Expr] {
    var tokens = Parser.tokenize(input.replacingOccurrences(of: "\n", with: " "))
    var exprs: [Expr] = []
    while !tokens.isEmpty {
      let (expr, remaining) = try Parser.next(tokens)
      tokens = remaining
      exprs.append(expr)
    }
    return exprs
  }
  
  static func tokenize(_ s: String) -> [String] {
    return specialSymbols.reduce(s, { (acc, symb) in
      acc.replacingOccurrences(of: symb, with: " \(symb) ")
    }).split(separator: " ").map { String($0) }
  }
  
  static func next(_ tokens: [String]) throws -> (Expr, [String]) {
    if tokens.isEmpty {
      return (.list([]), tokens)
    }
    
    var workingTokens = tokens
    switch workingTokens[0] {
    
    case "(":
      workingTokens.removeFirst()
      var elements: [Expr] = []
      while !workingTokens.isEmpty && workingTokens[0] != ")" {
        let (element, remainingTokens) = try next(workingTokens)
        workingTokens = remainingTokens
        elements.append(element)
      }
      
      if workingTokens.isEmpty {
        throw ParseError.unmatchedOpenParen
      }
      
      workingTokens.removeFirst() // take off ")"
      return (.list(elements), workingTokens)
      
    case ")":
      throw ParseError.unmatchedCloseParen
      
    case "'":
      // quote
      workingTokens.removeFirst()
      let (element, remainingTokens) = try next(workingTokens)
      return (.quote(element), remainingTokens)
      
    case "\"":
      // string
      workingTokens.removeFirst()
      var elements: [String] = []
      while !workingTokens.isEmpty && workingTokens[0] != "\"" {
        elements.append(workingTokens.removeFirst())
      }
      
      if workingTokens.isEmpty {
        throw ParseError.unclosedString
      }
      
      workingTokens.removeFirst()
      let str = elements.joined(separator: " ")
      return (.string(str), workingTokens)
      
    default:
      let element = workingTokens.removeFirst()
      if let int = Int(element) {
        return (.int(int), workingTokens)
      }
      if let float = Double(element) {
        return (.float(float), workingTokens)
      }
      return (.atom(element), workingTokens)
    }
  }
}
