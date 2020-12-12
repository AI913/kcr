//
//  APIRequest.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

import JobOrder_Utility

/// APIRequestProtocol
/// @mockable
public protocol APIRequestProtocol {
    func get<T: Codable>(url: URL, token: String?, query: [URLQueryItem]?) -> AnyPublisher<T, Error>
    func get<T: Codable>(resUrl: URL, token: String?, dataId: String, query: [URLQueryItem]?) -> AnyPublisher<T, Error>
    func getImage<T>(resUrl: URL, token: String?, dataId: String) -> AnyPublisher<T, Error>
    func post<T1: Codable, T2: Codable>(resUrl: URL, token: String?, data: T1) -> AnyPublisher<T2, Error>
    func put<T1: Codable, T2: Codable>(resUrl: URL, token: String?, dataId: String, data: T1) -> AnyPublisher<T2, Error>
    func delete<T: Codable>(resUrl: URL, token: String?, dataId: String) -> AnyPublisher<T, Error>
}

/// APIRequest
public class APIRequest: APIRequestProtocol {

    private let successRange = 200..<300
    private let retryCount = 1
    private let session: URLSession = URLSession.shared
    private let cacheSec: TimeInterval = 5 * 60; //5分キャッシュ

    public init() {}

    /// GET METHOD
    public func get<T: Codable>(url: URL, token: String?, query: [URLQueryItem]? = nil) -> AnyPublisher<T, Error> {
        let request = buildGetRequest(url: url, token: token, query: query)

        return URLSession.shared.dataTaskPublisher(for: request)
            .validate(statusCode: successRange)
            .retry(retryCount)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// GET METHOD
    public func get<T: Codable>(resUrl: URL, token: String?, dataId: String, query: [URLQueryItem]? = nil) -> AnyPublisher<T, Error> {
        let url = resUrl.appendingPathComponent(dataId)
        return get(url: url, token: token, query: query)
    }

    /// GET METHOD
    public func getImage<T>(resUrl: URL, token: String?, dataId: String) -> AnyPublisher<T, Error> {
        let url = resUrl.appendingPathComponent(dataId)

        var request: URLRequest = URLRequest(url: url,
                                             cachePolicy: .returnCacheDataElseLoad,
                                             timeoutInterval: cacheSec)

        request.httpMethod = "GET"
        request.addValue("image/*", forHTTPHeaderField: "Content-Type")
        if token != nil {
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .validate(statusCode: successRange)
            .retry(retryCount)
            .tryMap({ $0 as! T })
            .eraseToAnyPublisher()
    }

    /// POST METHOD
    public func post<T1: Codable, T2: Codable>(resUrl: URL, token: String?, data: T1) -> AnyPublisher<T2, Error> {

        var request: URLRequest = URLRequest(url: resUrl)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if token != nil {
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        if let postData = try? encoder.encode(data) {
            request.httpBody = postData as Data
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .validate(statusCode: successRange)
            .retry(retryCount)
            .decode(type: T2.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// PUT METHOD
    public func put<T1: Codable, T2: Codable>(resUrl: URL, token: String?, dataId: String, data: T1) -> AnyPublisher<T2, Error> {

        let url = resUrl.appendingPathComponent(dataId)
        var request: URLRequest = URLRequest(url: url)

        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if token != nil {
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        if let postData = try? encoder.encode(data) {
            request.httpBody = postData as Data
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .validate(statusCode: successRange)
            .retry(retryCount)
            .decode(type: T2.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// DELETE METHOD
    public func delete<T: Codable>(resUrl: URL, token: String?, dataId: String) -> AnyPublisher<T, Error> {

        let url = resUrl.appendingPathComponent(dataId)
        var request: URLRequest = URLRequest(url: url)

        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if token != nil {
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .validate(statusCode: successRange)
            .retry(retryCount)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Function
extension APIRequest {

    func buildGetRequest(url: URL, token: String?, query: [URLQueryItem]?) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        if let query = query, !query.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = query
            request.url = components?.url
        }

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if token != nil {
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }
        Logger.debug(target: self, "request url: \(request.url?.absoluteString ?? "nil")")
        return request
    }

}

extension URLSession.DataTaskPublisher {

    func validate<S: Sequence>(statusCode range: S) -> Publishers.TryMap<Self, Data> where S.Iterator.Element == Int {
        tryMap { data, response -> Data in
            switch (response as? HTTPURLResponse)?.statusCode {
            case .some(let code) where range.contains(code):
                return data
            case .some(let code) where !range.contains(code):
                throw APIError.invalidStatus(code, String(data: data, encoding: .utf8))
            default:
                throw APIError.networkError(String(data: data, encoding: .utf8))
            }
        }
    }
}

enum APIError: Error {
    case exception(Error)
    case networkError(String?)
    case invalidStatus(Int, String?)
    case noDataInResponse
    case parseError(Error)
}
