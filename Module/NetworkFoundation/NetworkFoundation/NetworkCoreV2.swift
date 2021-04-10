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
  func networkCore(
    networkEnvironment path: String, method: ResourceTargetHTTPMethod
  ) -> NetworkEnvironment
  func networkCore<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?
  ) -> AnyPublisher<T, Exception>?
}

public extension NetworkCoreV2Delegate {
  func networkCore<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?
  ) -> AnyPublisher<T, Exception>? { nil }
}

public protocol NetworkCoreV2Protocol {
  func upload<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?,
    multipartFormData: @escaping (MultiPartFormDataProtocol) -> Void,
    expect: T.Type
  ) -> AnyPublisher<T, Exception>
  func request<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?,
    expect: T.Type
  ) -> AnyPublisher<T, Exception>
}


public final class NetworkCoreV2 {
  public let shared = NetworkCore()
  
  public static func upload<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V? = nil,
    multipartFormData: @escaping (MultiPartFormDataProtocol) -> Void,
    expect: T.Type,
    delegate: NetworkCoreV2Delegate
  ) -> AnyPublisher<T, Exception> {
    let logger = Logger()
    let publisher: AnyPublisher<T, Exception> = Future { callback in
      let parameters: [String: Any] = self.getParameters(
        path: path,
        method: method,
        parameters: parameters,
        logger: logger,
        callback: callback
      ) ?? [:]
      let networkEnvironment = delegate.networkCore(
        networkEnvironment: path,
        method: method
      )
      let absoluteUrl: String = self.makeAbsoluteUrl(
        path: path,
        method: method,
        parameters: method == .get ? parameters : nil,
        logger: logger,
        networkEnvironment: networkEnvironment,
        callback: callback
      )
      let startTime = Date.now
      
      logger.enqueue("\(method) \(absoluteUrl)", logLevel: .info)
      
      AF.upload(
        multipartFormData: multipartFormData,
        to: absoluteUrl,
        usingThreshold: UInt64(),
        method: method.alamofireMethodBridge,
        headers: HTTPHeaders(networkEnvironment.headers),
        interceptor: nil,
        fileManager: .default
      ).responseData { response in
        self.handleResponse(
          response: response,
          path: path,
          method: method,
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
  
  public static func request<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V? = nil,
    expect: T.Type,
    delegate: NetworkCoreV2Delegate
  ) -> AnyPublisher<T, Exception> {
    let logger = Logger()
    let publisher: AnyPublisher<T, Exception> = Future { callback in
      do {
        let parameters: [String: Any] = self.getParameters(
          path: path,
          method: method,
          parameters: parameters,
          logger: logger,
          callback: callback
        ) ?? [:]
        let networkEnvironment = delegate.networkCore(
          networkEnvironment: path,
          method: method
        )
        let absoluteUrl: String = self.makeAbsoluteUrl(
          path: path,
          method: method,
          parameters: method == .get ? parameters : nil,
          logger: logger,
          networkEnvironment: networkEnvironment,
          callback: callback
        )
        let startTime = Date.now

        logger.enqueue("\(method) \(absoluteUrl)", logLevel: .info)
        if parameters.isNotEmpty, method != .get {
          let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
          if let jsonString = String(data: data, encoding: .utf8) {
            logger.enqueue(jsonString, logLevel: .verbose)
          } else {
            logger.enqueue("could not parse parameters JSON", logLevel: .error)
          }
        }
        
        AF.request(
          absoluteUrl,
          method: method.alamofireMethodBridge,
          parameters: method == .get ? nil : parameters,
          encoding: JSONEncoding.default,
          headers: HTTPHeaders(networkEnvironment.headers),
          interceptor: nil
        ).responseData { response in
          self.handleResponse(
            response: response,
            path: path,
            method: method,
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
  
  private static func handleResponse<T: Codable>(
    response: AFDataResponse<Data>,
    path: String,
    method: ResourceTargetHTTPMethod,
    logger: Logger,
    startTime: Date,
    callback: (Result<T, Exception>) -> Void
  ) {
//    let requestDuration = Date.now.timeIntervalSince(startTime).rounded(toPlaces: 2)
//    let statusCode = response.response.flatMap {
//      "\($0.statusCode)"
//    } ?? ""
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
          if let response = EmptyResponseBody() as? T {
            callback(.success(response))
          } else {
            callback(.failure(Exception(NetworkError.noData)))
          }
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
          let json = try jsonDecoder.decode(T.self, from: data)
          logger.enqueue(json.prettyJSONString, logLevel: .info)
          callback(.success(json))
        }
      } catch let error {
        logger.enqueue(error, logLevel: .error)
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
          logger.enqueue(string, logLevel: .error)
        }
        if let response = EmptyResponseBody() as? T {
          callback(.success(response))
        } else {
          callback(.failure(Exception(error)))
        }
      }
    } else {
      logger.enqueue("No Content", logLevel: .error)
      if let response = EmptyResponseBody() as? T {
        callback(.success(response))
      } else {
        callback(.failure(Exception(NetworkError.noData)))
      }
    }
  }
  
  public static func getParameters<T: Codable, V: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?,
    logger: Logger,
    callback: (Result<T, Exception>) -> Void
  ) -> [String: Any]? {
    let parameters: [String: Any]? = {
      if let parameters = parameters {
        do {
          let data = try jsonEncoder.encode(parameters)
          if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            if method == .get {
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
  
  private static func makeAbsoluteUrl<T: Codable>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: [String: Any]?,
    logger: Logger,
    networkEnvironment: NetworkEnvironment,
    callback: (Result<T, Exception>) -> Void
  ) -> String {
    let absoluteUrl: String = {
      do {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkEnvironment.scheme
        urlComponents.host = networkEnvironment.host
        urlComponents.port = networkEnvironment.port
        urlComponents.path = networkEnvironment.path + path
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
