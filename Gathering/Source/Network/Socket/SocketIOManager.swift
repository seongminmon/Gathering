//
//  SocketIOManager.swift
//  Gathering
//
//  Created by 김성민 on 12/4/24.
//

import Foundation
import Combine

import SocketIO

enum SocketInfo<ModelType: Decodable>: String {
    case channel
    case dm
    
    var namespace: String {
        switch self {
        case .channel: 
            return "/ws-channel"
        case .dm: 
            return "/ws-dm"
        }
    }
}

final class SocketIOManager<ModelType: Decodable> {
    
    private var id: String
    private var socketInfo: SocketInfo<ModelType>
    private var socketManager: SocketManager?
    private var socket: SocketIOClient?
    
    init(
        id: String,
        socketInfo: SocketInfo<ModelType>,
        completionHandler: @escaping (Result<ModelType, Error>) -> Void
    ) {
        self.id = id
        self.socketInfo = socketInfo
        
        configureSocket()
        configureConnectionEvents()
        configureSocketEvents(completionHandler)
        connect()
    }
    
    deinit {
        print("소켓 매니저 Deinit")
        disconnect()
    }
    
    private func configureSocket() {
        guard let baseURL = URL(string: String(APIAuth.baseURL.dropLast())) else {
            print("baseURL 없음")
            return
        }
        
        socketManager = SocketManager(
            socketURL: baseURL,
            config: [.log(true), .compress]
        )
        socket = socketManager?.socket(forNamespace: "\(socketInfo.namespace)-\(id)")
    }
    
    private func configureConnectionEvents() {
        guard let socket = socket else { return }
        
        socket.on(clientEvent: .connect) { _, _ in
            print("소켓 연결 감지")
        }
        
        socket.on(clientEvent: .disconnect) { _, _ in
            print("소켓 연결 해제 감지")
        }
        
        socket.on(clientEvent: .reconnect) { _, _ in
            print("소켓 재연결 감지")
        }
    }
    
    private func configureSocketEvents(
        _ completionHandler: @escaping (Result<ModelType, Error>) -> Void
    ) {
        guard let socket = socket else { return }
        
        socket.on(socketInfo.rawValue) { dataArray, _ in
            print("소켓 데이터 이벤트 감지")
            
            guard let data = dataArray.first else {
                print("소켓 데이터 없음")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decodedData = try JSONDecoder().decode(ModelType.self, from: jsonData)
                completionHandler(.success(decodedData))
            } catch {
                print("소켓 데이터 디코딩 실패")
                completionHandler(.failure(error))
            }
        }
    }
    
    private func connect() {
        print("소켓 연결")
        socket?.connect()
    }
    
    private func disconnect() {
        print("소켓 연결 끊기")
        socket?.disconnect()
        socket?.off(clientEvent: .connect)
        socket?.off(clientEvent: .disconnect)
        socket?.off(clientEvent: .reconnect)
        socket?.off(socketInfo.rawValue)
        socket = nil
        socketManager = nil
    }
}
