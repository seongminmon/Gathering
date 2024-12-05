//
//  SocketIOManager.swift
//  Gathering
//
//  Created by 김성민 on 12/4/24.
//

import Foundation
import Combine

import SocketIO

enum SocketInfo {
    case channel
    case dm
}

final class SocketIOManager<Model: Decodable> {
    
    private var id: String
    private var socketInfo: SocketInfo
    private var socketManager: SocketManager?
    private var socket: SocketIOClient?
    
    init(id: String, socketInfo: SocketInfo, completionHandler: @escaping (Model) -> Void) {
        self.id = id
        self.socketInfo = socketInfo
        
        createSocket()
        setSocket(completionHandler)
    }
    
    deinit {
        print("소켓 매니저 Deinit")
    }
    
    private func createSocket() {
        guard let baseURL = URL(string: String(APIAuth.baseURL.dropLast())) else {
            print("baseURL 없음")
            return
        }
        
        socketManager = SocketManager(
            socketURL: baseURL,
            config: [.log(true), .compress]
        )
        
        socket = switch socketInfo {
        case .channel:
            socketManager?.socket(forNamespace: "/ws-channel-\(id)")
        case .dm:
            socketManager?.socket(forNamespace: "/ws-dm-\(id)")
        }
    }
    
    private func setSocket<T: Decodable>(_ completionHandler: @escaping (T) -> Void) {
        switch socketInfo {
        case .channel:
            // 소켓 연결 메서드
            socket?.on(clientEvent: .connect) { data, ack in
                print("채널 소켓 연결", data, ack)
            }
            
            // 소켓이 연결된 이후에는 “channel” Event 를 통해 채팅을 수신
            socket?.on("channel") { dataArray, ack in
                print("채널 소켓 데이터 전달", dataArray, ack)
                do {
                    let data = dataArray[0]
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decodedData = try JSONDecoder().decode(
                        T.self,
                        from: jsonData
                    )
                    print("디코딩된 데이터", decodedData)
                    completionHandler(decodedData)
                } catch {
                    print("채널 데이터 변환 실패", error)
                }
            }
            
            // 소켓 해제 메서드
            socket?.on(clientEvent: .disconnect) { data, ack in
                print("채널 소켓 연결 해제", data, ack)
            }
            
            // 소켓 재연결 메서드
            socket?.on(clientEvent: .reconnect) { data, ack in
                print("채널 소켓 재연결", data, ack)
            }
        case .dm:
            // 소켓 연결 메서드
            socket?.on(clientEvent: .connect) { data, ack in
                print("DM 소켓 연결", data, ack)
            }
            
            // 소켓이 연결된 이후에는 “dm” Event 를 통해 채팅을 수신
            socket?.on("dm") { dataArray, ack in
                print("DM 소켓 데이터 전달", dataArray, ack)
                do {
                    let data = dataArray[0]
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
                    print("디코딩된 데이터", decodedData)
                    completionHandler(decodedData)
                } catch {
                    print("DM 데이터 변환 실패", error)
                }
            }
            
            // 소켓 해제 메서드
            socket?.on(clientEvent: .disconnect) { data, ack in
                print("DM 소켓 연결 해제", data, ack)
            }
            
            // 소켓 재연결 메서드
            socket?.on(clientEvent: .reconnect) { data, ack in
                print("DM 소켓 재연결", data, ack)
            }
        }
    }
    
    func connect() {
        print("소켓 연결", socket == nil)
        socket?.connect()
    }
    
    func disconnect() {
        print("소켓 연결 끊기")
        socket?.disconnect()
        socket?.off(clientEvent: .connect)
        socket?.off(clientEvent: .disconnect)
        socket?.off(clientEvent: .reconnect)
        switch socketInfo {
        case .channel:
            socket?.off("channel")
        case .dm:
            socket?.off("dm")
        }
        socket = nil
        socketManager = nil
    }
}
