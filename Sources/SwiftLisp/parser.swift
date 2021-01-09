import Foundation

protocol Parsable {
  init?(parse text: String)
}

extension Expr : Parsable {
  init?(parse text: String) {
    self = .nilexpr
    let tokens = tokenize(text)
    guard let (elements, _) = next(tokens) else {
      return nil
    }
    self = elements
  }

  private func tokenize(_ s: String) -> [String] {
    return s.replacingOccurrences(of: "(", with: " ( ")
      .replacingOccurrences(of: ")", with: " ) ")
      .split(separator: " ").map { String($0) }
  }

  private func next(_ tokens: [String]) -> (Expr, [String])? {
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
    default:
      let element = workingTokens.removeFirst()
      return (.atom(element), workingTokens)
    }
  }
}
