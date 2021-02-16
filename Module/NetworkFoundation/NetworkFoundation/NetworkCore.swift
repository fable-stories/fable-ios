//
//  NetworkCore.swift
//  App
//
//  Created by Andrew Aquino on 4/10/19.
//

import Foundation
import ReactiveSwift
import AppFoundation
import Alamofire

private let jsonEncoder: JSONEncoder = {
  let e = JSONEncoder()
  e.keyEncodingStrategy = .convertToSnakeCase
  return e
}()

private let jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
  d.keyDecodingStrategy = .convertFromSnakeCase
  return d
}()

public protocol ResourceTargetProtocol {
  associatedtype RequestBodyType: Codable
  associatedtype ResponseBodyType: Codable
  var url: String { get }
  var method: ResourceTargetHTTPMethod { get }
  func multipartFormdata() -> (MultiPartFormDataProtocol) -> Void
}

extension ResourceTargetProtocol {
  public func multipartFormdata() -> (MultiPartFormDataProtocol) -> Void {{ _ in }}
}

public struct EmptyRequestBody: Codable { public init() {} }
public struct EmptyResponseBody: Codable { public init() {} }

public enum ResourceTargetHTTPMethod: CustomStringConvertible {
  case get
  case post
  case put
  case delete
  
  public var description: String {
    switch self {
    case .get: return "GET"
    case .post: return "POST"
    case .put: return "PUT"
    case .delete: return "DELETE"
    }
  }
}

public protocol NetworkEnvironment {
  init(
    environment: Environment,
    scheme: String,
    host: String,
    port: Int?,
    path: String,
    headers: [String: String]
  )

  var environment: Environment { get }
  var scheme: String { get }
  var host: String { get }
  var port: Int? { get }
  var path: String { get }
  var headers: [String: String] { get }
}

public protocol NetworkCoreDelegate: class {
  func networkCore<T: ResourceTargetProtocol>(
    networkEnvironment forResourceTarget: T
  ) -> NetworkEnvironment
}

public protocol NetworkCoreProtocol {
  func upload<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?
  ) -> SignalProducer<T.ResponseBodyType?, NetworkError>
  func request<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?
  ) -> SignalProducer<T.ResponseBodyType?, NetworkError>
}

public protocol EnvironmentTargetType {
  init?(rawValue: String?)
}

public final class NetworkCore {
  public let shared = NetworkCore()

  public static func upload<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?, 
    delegate: NetworkCoreDelegate
  ) -> SignalProducer<T.ResponseBodyType?, NetworkError> {
    return SignalProducer { observer, lifetime in
      let logger = Logger()
      let parameters: [String: Any]? = self.getParameters(target, parameters: parameters, logger: logger, observer: observer)
      let networkEnvironment = delegate.networkCore(networkEnvironment: target)
      let absoluteUrl: String = self.makeAbsoluteUrl(
        target,
        parameters: parameters,
        logger: logger,
        networkEnvironment: networkEnvironment,
        observer: observer
      )
      let startTime = Date.now

      lifetime.observeEnded {
        logger.flush()
      }

      logger.enqueue("\(target.method) \(absoluteUrl)")
      
      AF.upload(
        multipartFormData: target.multipartFormdata(),
        to: absoluteUrl,
        usingThreshold: UInt64(),
        method: target.method.alamofireMethodBridge,
        headers: HTTPHeaders(networkEnvironment.headers),
        interceptor: nil, fileManager: .default
      ).responseData { response in
        self.handleResponse(
          observer: observer,
          response: response,
          target: target,
          logger: logger,
          startTime: startTime
        )
      }
    }
  }

  public static func request<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType? = nil,
    delegate: NetworkCoreDelegate
  ) -> SignalProducer<T.ResponseBodyType?, NetworkError> {
    return SignalProducer { observer, lifetime in
      do {
        let logger = Logger()
        let parameters: [String: Any] = self.getParameters(target, parameters: parameters, logger: logger, observer: observer) ?? [:]
        let networkEnvironment = delegate.networkCore(networkEnvironment: target)
        let absoluteUrl: String = self.makeAbsoluteUrl(
          target,
          parameters: target.method == .get ? parameters : nil,
          logger: logger,
          networkEnvironment: networkEnvironment,
          observer: observer
        )
        let startTime = Date.now

        lifetime.observeEnded {
          logger.flush()
        }
        
        logger.enqueue("\n\(target.method) \(absoluteUrl)", logLevel: .info)
        if parameters.isNotEmpty, target.method != .get {
          logger.enqueue("\n-- REQUEST --\n")
          let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
          if let jsonString = String(data: data, encoding: .utf8) {
            logger.enqueue(jsonString, logLevel: .verbose)
          } else {
            logger.enqueue("could not parse parameters JSON", logLevel: .error)
          }
        }
        
        AF.request(
          absoluteUrl,
          method: target.method.alamofireMethodBridge,
          parameters: target.method == .get ? nil : parameters,
          encoding: JSONEncoding.default,
          headers: HTTPHeaders(networkEnvironment.headers),
          interceptor: nil
        ).responseData { response in
          self.handleResponse(
            observer: observer,
            response: response,
            target: target,
            logger: logger,
            startTime: startTime
          )
        }
      } catch let error {
        observer.send(error: .parameterParsingFailed(error))
      }
    }
  }
  
  private static func handleResponse<T: ResourceTargetProtocol>(
    observer: Signal<T.ResponseBodyType?, NetworkError>.Observer,
    response: AFDataResponse<Data>,
    target: T,
    logger: Logger,
    startTime: Date
  ) {
    let requestDuration = Date.now.timeIntervalSince(startTime).rounded(toPlaces: 2)
    let statusCode = response.response.flatMap {
      "\($0.statusCode)"
    } ?? ""
    logger.enqueue("\n-- RESPONSE \(requestDuration)s \(statusCode) --\n")
    let targetType = type(of: target)
    if let error = response.error, response.response?.hasSuccessfulStatusCode != true {
      logger.enqueue(error, logLevel: .error)
      observer.send(error: .network(error, nil))
    } else if let data = response.data, data.isNotEmpty {
      do {
        let json: [String: Any] = try {
          if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return json
          }
          return [:]
        }()
        if json.isEmpty {
          logger.enqueue("no data", logLevel: .error)
          observer.send(value: nil)
          observer.sendCompleted()
        } else if let error = json["error"] as? String {
          logger.enqueue(error, logLevel: .error)
          observer.send(error: .network(nil, error))
        } else {
          let logData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
          if let jsonString = String(data: logData, encoding: .utf8) {
            logger.enqueue(jsonString, logLevel: .verbose)
          } else {
            logger.enqueue("could not parse response JSON", logLevel: .error)
          }
          let json = try jsonDecoder.decode(targetType.ResponseBodyType.self, from: data)
          observer.send(value: json)
          observer.sendCompleted()
        }
      } catch let error {
        logger.enqueue(error, logLevel: .error)
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
          logger.enqueue(string, logLevel: .error)
        }
        observer.send(value: nil)
        observer.sendCompleted()
      }
    } else {
      logger.enqueue("No Content", logLevel: .error)
      observer.send(value: nil)
      observer.sendCompleted()
    }
  }

  public static func getParameters<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?,
    logger: Logger,
    observer: Signal<T.ResponseBodyType?, NetworkError>.Observer
  ) -> [String: Any]? {
    let parameters: [String: Any]? = {
      if let parameters = parameters {
        do {
          let data = try jsonEncoder.encode(parameters)
          if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return json
          }
        } catch let error {
          logger.enqueue(error.localizedDescription, logLevel: .error)
          observer.send(error: .parameterParsingFailed(error))
        }
      }
      return nil
    }()
    return parameters
  }

  private static func makeAbsoluteUrl<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: [String: Any]?,
    logger: Logger,
    networkEnvironment: NetworkEnvironment,
    observer: Signal<T.ResponseBodyType?, NetworkError>.Observer
  ) -> String {
    let absoluteUrl: String = {
      do {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkEnvironment.scheme
        urlComponents.host = networkEnvironment.host
        urlComponents.port = networkEnvironment.port
        urlComponents.path = networkEnvironment.path + target.url
        if let parameters = parameters {
          let queryItems = parameters.compactMap { key, value -> URLQueryItem? in
            return URLQueryItem(name: key, value: String(describing: value))
          }
          if queryItems.isNotEmpty {
            urlComponents.queryItems = queryItems
          }
        }
        return try urlComponents.asURL().absoluteString
      } catch let error {
        logger.enqueue(error.localizedDescription, logLevel: .error)
        observer.send(error: .parameterParsingFailed(error))
        return ""
      }
    }()
    return absoluteUrl
  }
}

private extension ResourceTargetHTTPMethod {
  var alamofireMethodBridge: HTTPMethod {
    switch self {
    case .get: return .get
    case .post: return .post
    case .put: return .put
    case .delete: return .delete
    }
  }
}

public protocol MultiPartFormDataProtocol {
  func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String)
  func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?)
  func append(_ value: String, withName name: String)
}

extension MultipartFormData: MultiPartFormDataProtocol {
  public func append(_ value: String, withName name: String) {
    guard let data = value.data(using: .utf8) else { return }
    self.append(data, withName: name)
  }
}

private extension HTTPURLResponse {
  var hasSuccessfulStatusCode: Bool {
    statusCode.description.hasPrefix("2")
  }
}
