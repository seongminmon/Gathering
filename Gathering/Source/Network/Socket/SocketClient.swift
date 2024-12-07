//
//  SocketClient.swift
//  Gathering
//
//  Created by 김성민 on 12/4/24.
//

import Foundation

import ComposableArchitecture

struct SocketClient {
    //
}

extension SocketClient: DependencyKey {
    static let liveValue = SocketClient()
}

extension DependencyValues {
    var socketClient: SocketClient {
        get { self[SocketClient.self] }
        set { self[SocketClient.self] = newValue }
    }
}
