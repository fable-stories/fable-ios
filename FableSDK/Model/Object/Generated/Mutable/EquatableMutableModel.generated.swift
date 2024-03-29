// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
private func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
  switch (lhs, rhs) {
  case let (lValue?, rValue?):
    return compare(lValue, rValue)
  case (nil, nil):
    return true
  default:
    return false
  }
}

private func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
  guard lhs.count == rhs.count else { return false }
  for (idx, lhsItem) in lhs.enumerated() {
    guard compare(lhsItem, rhs[idx]) else { return false }
  }
  return true
}

// MARK: - EquatableMutableModel for classes, protocols, structs
