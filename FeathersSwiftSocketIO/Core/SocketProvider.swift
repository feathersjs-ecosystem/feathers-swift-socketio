//
//  SocketProvider.swift
//  FeathersSwiftSocketIO
//
//  Created by Brendan Conron on 5/16/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import SocketIO
import Foundation
import enum Result.Result
import enum Result.NoError
import Feathers
import ReactiveSwift

public final class SocketProvider: Provider {

    public let baseURL: URL

    public var supportsRealtimeEvents: Bool {
        return true
    }
    
    /// SocketIO client.
    private let client: SocketIOClient

    /// Socket timeout for `connect` and all emits.
    private let timeout: Double

    /// Socket provider initializer.
    ///
    /// - Parameters:
    ///   - baseURL: Socket url.
    ///   - configuration: Socket configuration object. See `SocketIO` for more details
    /// on the possible options.
    ///   - timeout: Socket timeout.
    public init(manager: SocketManager, timeout: Double = 5) {
        self.baseURL = manager.socketURL
        self.timeout = timeout
        client = manager.defaultSocket
    }

    public func setup(app: Feathers) {
        // Attempt to authenticate using a previously stored token once the client connects.
        client.once("connect") { [weak app = app, weak self] data, ack in
            guard let vSelf = self else { return }
            guard let vApp = app else { return }
            guard let accessToken = vApp.authenticationStorage.accessToken else { return }
            vSelf.emit(to: "authenticate", with: [
                "strategy": vApp.authenticationConfiguration.jwtStrategy,
                "accessToken": accessToken
            ])
                .on(failed: { _ in
                    vApp.authenticationStorage.accessToken = accessToken
                }, value: { value in
                    if case let .object(object) = value.data,
                        let json = object as? [String: Any],
                        let accessToken = json["accessToken"] as? String {
                        vApp.authenticationStorage.accessToken = accessToken
                    }
                })
            .start()
        }
        client.connect(timeoutAfter: timeout) {
            print("feathers socket failed to connect")
        }
    }

    public func request(endpoint: Endpoint) -> SignalProducer<Response, AnyFeathersError> {
        let emitPath = endpoint.method.socketRequestPath
        return emit(to: emitPath, with: [endpoint.path] + endpoint.method.socketData)
    }

    public func authenticate(_ path: String, credentials: [String : Any]) -> SignalProducer<Response, AnyFeathersError> {
        return emit(to: "authenticate", with: credentials)
    }

    public func logout(path: String) -> SignalProducer<Response, AnyFeathersError> {
        return emit(to: "logout", with: [])
    }

    /// Emit data to a given path.
    ///
    /// - Parameters:
    ///   - path: Path to emit on.
    ///   - data: Data to emit.
    ///   - completion: Completion callback.
    private func emit(to path: String, with data: SocketData) -> SignalProducer<Response, AnyFeathersError> {
        return SignalProducer { [weak self] observer, disposable in
            guard let vSelf = self else {
                observer.sendInterrupted()
                return
            }
            if vSelf.client.status == .connecting {
                vSelf.client.once("connect") { _,_  in
                    vSelf.client.emitWithAck(path, data).timingOut(after: vSelf.timeout) { data in
                        let result = vSelf.handleResponseData(data: data)
                        if let error = result.error {
                            observer.send(error: error)
                        } else if let response = result.value {
                            observer.send(value: response)
                        } else {
                            observer.send(error: AnyFeathersError(FeathersNetworkError.unknown))
                        }
                    }
                }
            } else {
                vSelf.client.emitWithAck(path, data).timingOut(after: vSelf.timeout) { data in
                    let result = vSelf.handleResponseData(data: data)
                    if let error = result.error {
                        observer.send(error: error)
                    } else if let response = result.value {
                        observer.send(value: response)
                    } else {
                        observer.send(error: AnyFeathersError(FeathersNetworkError.unknown))
                    }
                }
            }

        }
    }

    /// Parse and handle socket response data.
    ///
    /// - Parameter data: Socket response data.
    /// - Returns: Result object with error or response.
    private func handleResponseData(data: [Any]) -> Result<Response, AnyFeathersError> {
        if let noAck = data.first as? String, noAck == "NO ACK" {
            return .failure(AnyFeathersError(FeathersNetworkError.notFound))
        } else if let errorData = data.first as? [String: Any], let code = errorData["code"] as? Int, let error = FeathersNetworkError(statusCode: code) {
            return .failure(AnyFeathersError(error))
        } else if let jsonObject = data.last as? [String: Any] {
            if let pagination = parsePagination(data: jsonObject), let data = jsonObject["data"] as? [Any] {
                return .success(Response(pagination: pagination, data: .list(data)))
            }
            return .success(Response(pagination: nil, data: .object(jsonObject)))
        } else if let jsonArray = data.last as? [Any] {
            return .success(Response(pagination: nil, data: .list(jsonArray)))
        }
        return .failure(AnyFeathersError(FeathersNetworkError.unknown))
    }

    /// Parse pagination data if any.
    ///
    /// - Parameter data: Data to parse from.
    /// - Returns: Paginiation object or nil.
    private func parsePagination(data: [String: Any]) -> Pagination? {
        guard
            let limit = data["limit"] as? Int,
            let skip = data["skip"] as? Int,
            let total = data["total"] as? Int else {
                return nil
        }
        return Pagination(total: total, limit: limit, skip: skip)
    }

    // MARK: - RealTimeProvider

    public func on(event: String) -> Signal<[String: Any], NoError> {
        return Signal { [weak client = client] observer, lifetime in
            guard let vClient = client else {
                observer.sendInterrupted()
                return
            }
            vClient.on(event, callback: { data, _ in
                guard let object = data.first as? [String: Any] else { return }
                observer.send(value: object)
            })
            let disposable = AnyDisposable {
                vClient.off(event)
            }
            lifetime += disposable
        }
    }

    public func once(event: String) -> Signal<[String: Any], NoError> {
        return Signal { [weak client = client] observer, lifetime in
            guard let vClient = client else {
                observer.sendInterrupted()
                return
            }
            vClient.once(event, callback: { data, _ in
                guard let object = data.first as? [String: Any] else { return }
                observer.send(value: object)
                observer.sendCompleted()
            })
            let disposable = AnyDisposable {
                vClient.off(event)
            }
            lifetime += disposable
        }
    }

    public func off(event: String) {
        client.off(event)
    }

    // MARK: - Deinit

    deinit {
        client.disconnect()
    }

}

fileprivate extension Service.Method {

    fileprivate var socketRequestPath: String {
        switch self {
        case .find: return "find"
        case .get: return "get"
        case .create: return "create"
        case .update: return "update"
        case .patch: return "patch"
        case .remove: return "removed"
        }
    }

    fileprivate var socketData: [SocketData?] {
        switch self {
        case .find(let query):
            return [query?.serialize() ?? [:]]
        case .get(let id, let query):
            return [id, query?.serialize() ?? [:]]
        case .create(let data, let query):
            return [data, query?.serialize() ?? [:]]
        case .update(let id, let data, let query),
             .patch(let id, let data, let query):
            return [id ?? nil, data, query?.serialize() ?? [:]]
        case .remove(let id, let query):
            return [id ?? nil, query?.serialize()]
        }
    }
    
}

