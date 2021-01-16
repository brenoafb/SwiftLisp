import Foundation

func valueToExpr(_ value: Any) -> Expr? {
  if let value = value as? Int {
    return .int(value)
  }

  if let value = value as? Double {
    return .float(value)
  }

  if let value = value as? String {
    return .string(value)
  }

  if let value = value as? [String:Any] {
    return dictToAssocList(value)
  }

  if let value = value as? [Any] {
    return arrayToList(value)
  }

  return nil
}

func arrayToList(_ arr: [Any]) -> Expr? {
  var list: [Expr] = []
  for elem in arr {
    guard let expr = valueToExpr(elem) else {
      return nil
    }
    list.append(expr)
  }

  return .list(list)
}

func dictToAssocList(_ dict: [String:Any]) -> Expr? {
  var list: [Expr] = []

  for (key, value) in dict {
    guard let expr = valueToExpr(value) else {
      return nil
    }

    list.append(.list([.string(key), expr]))
  }

  return .list(list)
}

