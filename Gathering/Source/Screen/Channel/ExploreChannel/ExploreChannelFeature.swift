//
//  ExploreChannelFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture
    
@Reducer
struct ExploreChannelFeature {
    
    @Dependency(\.channelClient) var channelClient
    
    @ObservableState
    struct State {
        var channels: [Channel] = []
        var selectedChannel: Channel?
        var showAlert = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case channelTap(Channel)
        case confirmJoinChannel
        case cancelJoinChannel
        case applyInitialData([Channel])
        
        case task
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .channelTap(channel):
                state.selectedChannel = channel
                state.showAlert = true
                return .none
                
            case .confirmJoinChannel:
                // 여기에 채널 참여 로직 추가
                state.showAlert = false
                return .none
                
            case .cancelJoinChannel:
                state.showAlert = false
                state.selectedChannel = nil
                return .none
            case .task:
                return .run { send in
                    do {
                        async let channelList = try await fetchInitialData()
                        try await send(.applyInitialData(channelList))
                    } catch {
                        
                    }
                }
                
            case .applyInitialData(let channelList):
                state.channels = channelList
                return .none
            }
            
        }
    }
    
    private func fetchInitialData() async throws -> [Channel] {
        // 내가 속한 워크스페이스 리스트 조회
        let workspaceID = UserDefaultsManager.workspaceID
        async let channels = channelClient.fetchChannelList(workspaceID)
        
        return try await channels.map { $0.toChannel }
    }
}
