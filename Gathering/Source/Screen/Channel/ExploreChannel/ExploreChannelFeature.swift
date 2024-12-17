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
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        var allChannels: [Channel] = []
        var myChannels: [Channel] = []
        var selectedChannel: Channel?
        var showAlert = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case moveToChannelChattingView(Channel)
        
        case channelTap(Channel)
        case confirmJoinChannel(Channel?)
        case cancelJoinChannel
        case applyInitialData([Channel], [Channel])
        
        case task
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .channelTap(channel):
                if state.myChannels.contains(channel) {
                    return .send(.moveToChannelChattingView(channel))
                } else {
                    state.selectedChannel = channel
                    state.showAlert = true
                    return .none
                }
                
            case .moveToChannelChattingView:
                // 홈 뷰에서 destination으로 처리
                return .none
                
            case let .confirmJoinChannel(channel):
                guard let channel else { return .none }
                
                state.showAlert = false
                return .run { send in
                    do {
                        _ = try await channelClient.fetchChattingList(
                            channel.id,
                            UserDefaultsManager.workspaceID,
                            ""
                        )
                        await send(.moveToChannelChattingView(channel))
                        
                    } catch {
                        print("채널 참여 실패")
                    }
                }
                
            case .cancelJoinChannel:
                state.showAlert = false
                state.selectedChannel = nil
                return .none
                
            case .task:
                return .run { send in
                    do {
                        let (allChannels, myChannels) = try await fetchInitialData()
                        await send(.applyInitialData(allChannels, myChannels))
                    } catch {}
                }
                
            case .applyInitialData(let allChannels, let myChannels):
                state.allChannels = allChannels
                state.myChannels = myChannels
                return .none
            }
            
        }
    }
    
    private func fetchInitialData() async throws -> ([Channel], [Channel]) {
        let workspaceID = UserDefaultsManager.workspaceID
        async let allChannels = channelClient.fetchChannelList(workspaceID)
        async let myChannels = channelClient.fetchMyChannelList(workspaceID)
        return try await (
            allChannels.map { $0.toPresentModel() },
            myChannels.map { $0.toPresentModel() }
        )
    }
}
