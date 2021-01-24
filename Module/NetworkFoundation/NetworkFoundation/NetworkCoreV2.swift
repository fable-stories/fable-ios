//
//  NetworkCoreV2.swift
//  NetworkFoundation
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import Combine
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

public protocol NetworkCoreV2Delegate: class {
  func networkCore<T: ResourceTargetProtocol>(
    networkEnvironment forResourceTarget: T
  ) -> NetworkEnvironment
  func networkCore<T: ResourceTargetProtocol>(
    stubRequest target: T,
    parameters: T.RequestBodyType?
  ) -> AnyPublisher<T.ResponseBodyType?, Exception>?
}

public extension NetworkCoreV2Delegate {
  func networkCore<T: ResourceTargetProtocol>(
    stubRequest target: T,
    parameters: T.RequestBodyType?
  ) -> AnyPublisher<T.ResponseBodyType?, Exception>? { nil }
}


public protocol NetworkCoreV2Protocol {
  func upload<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?
  ) -> AnyPublisher<T.ResponseBodyType?, Exception>
  func request<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?
  ) -> AnyPublisher<T.ResponseBodyType?, Exception>
}


public final class NetworkCoreV2 {
  public let shared = NetworkCore()
  
  public static func upload<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?,
    delegate: NetworkCoreV2Delegate
  ) -> AnyPublisher<T.ResponseBodyType?, Exception> {
    let logger = Logger()
    let publisher: AnyPublisher<T.ResponseBodyType?, Exception> = Future { callback in
      let parameters: [String: Any]? = self.getParameters(target, parameters: parameters, logger: logger, callback: callback)
      let networkEnvironment = delegate.networkCore(networkEnvironment: target)
      let absoluteUrl: String = self.makeAbsoluteUrl(
        target,
        parameters: parameters,
        logger: logger,
        networkEnvironment: networkEnvironment,
        callback: callback
      )
      let startTime = Date.now
      
      logger.enqueue("\n\(target.method) \(absoluteUrl)", logLevel: .info)
      
      AF.upload(
        multipartFormData: target.multipartFormdata(),
        to: absoluteUrl,
        usingThreshold: UInt64(),
        method: target.method.alamofireMethodBridge,
        headers: HTTPHeaders(networkEnvironment.headers),
        interceptor: nil,
        fileManager: .default
      ).responseData { response in
        self.handleResponse(
          response: response,
          target: target,
          logger: logger,
          startTime: startTime,
          callback: callback
        )
      }
    }.eraseToAnyPublisher()
    
    publisher.sinkDisposed { _ in
      logger.flush()
    } receiveValue: { _ in
    }

    return publisher
  }
  
  public static func request<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType? = nil,
    delegate: NetworkCoreV2Delegate
  ) -> AnyPublisher<T.ResponseBodyType?, Exception> {
    if let stubRequest = delegate.networkCore(stubRequest: target, parameters: parameters) {
      return stubRequest
    }
    let logger = Logger()
    let publisher: AnyPublisher<T.ResponseBodyType?, Exception> = Future { callback in
      do {
        let parameters: [String: Any] = self.getParameters(target, parameters: parameters, logger: logger, callback: callback) ?? [:]
        let networkEnvironment = delegate.networkCore(networkEnvironment: target)
        let absoluteUrl: String = self.makeAbsoluteUrl(
          target,
          parameters: target.method == .get ? parameters : nil,
          logger: logger,
          networkEnvironment: networkEnvironment,
          callback: callback
        )
        let startTime = Date.now

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
            response: response,
            target: target,
            logger: logger,
            startTime: startTime,
            callback: callback
          )
        }
      } catch let error {
        callback(.failure(Exception(NetworkError.parameterParsingFailed(error))))
      }
    }.eraseToAnyPublisher()
    
    publisher.sinkDisposed { _ in
      logger.flush()
    } receiveValue: { _ in
    }

    return publisher
  }
  
  private static func handleResponse<T: ResourceTargetProtocol>(
    response: AFDataResponse<Data>,
    target: T,
    logger: Logger,
    startTime: Date,
    callback: (Result<T.ResponseBodyType?, Exception>) -> Void
  ) {
    let requestDuration = Date.now.timeIntervalSince(startTime).rounded(toPlaces: 2)
    let statusCode = response.response.flatMap {
      "\($0.statusCode)"
    } ?? ""
    logger.enqueue("\n-- RESPONSE \(requestDuration)s \(statusCode) --\n")
    let targetType = type(of: target)
    if let error = response.error, response.response?.hasSuccessfulStatusCode != true {
      logger.enqueue(error, logLevel: .error)
      callback(.failure(Exception(NetworkError.network(error, nil))))
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
          callback(.success(nil))
        } else if let error = json["error"] as? String {
          logger.enqueue(error, logLevel: .error)
          callback(.failure(Exception(NetworkError.network(nil, error))))
        } else {
          let logData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
          if let jsonString = String(data: logData, encoding: .utf8) {
            logger.enqueue(jsonString, logLevel: .verbose)
          } else {
            logger.enqueue("could not parse response JSON", logLevel: .error)
          }
          let json = try jsonDecoder.decode(targetType.ResponseBodyType.self, from: data)
          callback(.success(json))
        }
      } catch let error {
        logger.enqueue(error, logLevel: .error)
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
          logger.enqueue(string, logLevel: .error)
        }
        callback(.success(nil))
      }
    } else {
      logger.enqueue("No Content", logLevel: .error)
      callback(.success(nil))
    }
  }
  
  public static func getParameters<T: ResourceTargetProtocol>(
    _ target: T,
    parameters: T.RequestBodyType?,
    logger: Logger,
    callback: (Result<T.ResponseBodyType?, Exception>) -> Void
  ) -> [String: Any]? {
    let parameters: [String: Any]? = {
      if let parameters = parameters {
        do {
          let data = try jsonEncoder.encode(parameters)
          if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            if target.method == .get {
              return json.map { key, value -> (String, Any) in
                /// The API currently only accepts camelCase query parameters
                let key = key.toCamelCase
                if let value = value as? Array<Any> {
                  /// For query parameters, make sure to convert arrays to argument form
                  return (key, value.map { "\($0)" }.joined(separator: ","))
                }
                return (key, value)
              }.toMap()
            }
            return json
          }
        } catch let error {
          logger.enqueue(error.localizedDescription, logLevel: .error)
          callback(.failure(Exception(NetworkError.parameterParsingFailed(error))))
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
    callback: (Result<T.ResponseBodyType?, Exception>) -> Void
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
        callback(.failure(Exception(NetworkError.parameterParsingFailed(error))))
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

private extension HTTPURLResponse {
  var hasSuccessfulStatusCode: Bool {
    statusCode.description.hasPrefix("2")
  }
}

private class FBSDKRequestInterceptor: RequestInterceptor {
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    print(urlRequest.allHTTPHeaderFields ?? [:])
    completion(.success(urlRequest))
  }
}
