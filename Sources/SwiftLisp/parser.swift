import Foundation

struct Parser {

  static func parse(_ input: String) -> [Expr]? {
    var tokens = Parser.tokenize(input.replacingOccurrences(of: "\n", with: " "))
    var exprs: [Expr] = []
    while !tokens.isEmpty {
      guard let (expr, remaining) = Parser.next(tokens) else {
        return nil
      }
      tokens = remaining
      exprs.append(expr)
    }
    return exprs
  }

  static func tokenize(_ s: String) -> [String] {
    return s.replacingOccurrences(of: "(", with: " ( ")
      .replacingOccurrences(of: ")", with: " ) ")
      .replacingOccurrences(of: "'", with: " ' ")
      .replacingOccurrences(of: "\"", with: " \" ")
      .split(separator: " ").map { String($0) }
  }

  static func next(_ tokens: [String]) -> (Expr, [String])? {
    if tokens.isEmpty {
      return (.list([]), tokens)
    }

    var workingTokens = tokens
    switch workingTokens[0] {

    case "(":
      workingTokens.removeFirst()
      var elements: [Expr] = []
      while workingTokens[0] != ")" {
        guard let (element, remainingTokens) = next(workingTokens) else {
          return nil
        }
        workingTokens = remainingTokens
        elements.append(element)
      }
      workingTokens.removeFirst()
      return (.list(elements), workingTokens)

    case ")":
      return nil

    case "'":
      // quote
      workingTokens.removeFirst()
      guard let (element, remainingTokens) = next(workingTokens) else {
        return nil
      }
      return (.quote(element), remainingTokens)

    case "\"":
      // string
      workingTokens.removeFirst()
      var elements: [String] = []
      while workingTokens[0] != "\"" {
        elements.append(workingTokens.removeFirst())
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
