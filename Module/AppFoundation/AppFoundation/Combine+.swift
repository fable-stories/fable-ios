//
//  Combine+.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 11/28/20.
//

import Combine

@available(iOS 13, *)
extension Future {
  public static func empty<T>() -> Future<T, Never> { Future<T, Never> { _ in } }
}

@available(iOS 13, *)
public func += (lhs: inout Set<AnyCancellable>, rhs: AnyCancellable) {
  lhs.insert(rhs)
}

@available(iOS 13, *)
public let EmptyCancellable: AnyCancellable = AnyCancellable {}

@available(iOS 13, *)
private var cancellables: Set<AnyCancellable> = []

@available(iOS 13, *)
extension AnyPublisher {
  public static func singleValue(_ value: Output) -> AnyPublisher {
    return Future<Output, Failure> { $0(.success(value)) }
      .eraseToAnyPublisher()
  }
}

@available(iOS 13, *)
extension AnyPublisher {
  public func mapVoid() -> AnyPublisher<Void, Failure> {
    return self.map { _ in () }.eraseToAnyPublisher()
  }
  
  /// A self-disposing sink function
  public func sinkDisposed(
    receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
    receiveValue: ((Output) -> Void)? = nil
  ) {
    var _cancellable: AnyCancellable?
    let cancellable = sink(
      receiveCompletion: { completion in
        if let cancellable = _cancellable {
          cancellables.remove(cancellable)
        }
        receiveCompletion?(completion)
      },
      receiveValue: { value in
        receiveValue?(value)
      })
    _cancellable = cancellable
    cancellables.insert(cancellable)
  }
}

public extension AnyPublisher {
  func mapException() -> AnyPublisher<Output, Exception> {
    mapError { Exception($0) }.eraseToAnyPublisher()
  }
}

public extension AnyPublisher where Failure == Exception {
  func also(_ closure: @escaping () -> Void) -> AnyPublisher<Output, Failure> {
    map { i in
      closure()
      return i
    }.eraseToAnyPublisher()
  }
}
