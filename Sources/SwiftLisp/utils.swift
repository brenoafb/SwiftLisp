import Foundation

func sequenceArray<T>(_ xs: [T?]) -> [T]? {
  if xs.contains(where: { $0 == nil }) {
    return nil
  }
  return xs.map { $0! }
}
