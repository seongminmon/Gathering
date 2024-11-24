//
//  ChannelChattingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelChattingFeature {
    
    @Dependency(\.channelClient) var channelClient
    
    @Reducer
    enum Path {
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var channelID: String
        var workspaceID: String
        var currentChannel: ChannelResponse?
        var message: [ChattingPresentModel] = []
        
        var messageText = ""
        var selectedImages: [UIImage] = []
        var scrollViewID = UUID()
        var keyboardHeight: CGFloat = 0
        
        var messageButtonValid = false
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        
        case task
        case sendButtonTap
        case settingButtonTap
        
        case currentChannelResponse(ChannelResponse?)
        
        case channelChattingResponse([ChattingPresentModel])
        
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .settingButtonTap:
                state.path.append(
                    .channelSetting(ChannelSettingFeature.State()))
                return .none
                
            case .path:
                return .none
                
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !state.selectedImages.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .binding(_):
                return .none
                
            case .task:
                return .run { [channelID = state.channelID, workspaceID = state.workspaceID] send in
                    do {
                        let channel = try await fetchChannel(
                            channelID: channelID,
                            workspaceID: workspaceID)
                        await send(.currentChannelResponse(channel))
                        
                        let message = try await fetchChannelChatting(
                            channelID: channelID,
                            workspaceID: workspaceID,
                            cursorDate: ""
                        )
                        await send(.channelChattingResponse(message))
                    } catch {
                        print("채팅 패치 실패")
                    }
                }
                
            case .sendButtonTap:
                //db
                return .none
                
            case .currentChannelResponse(let channel):
                state.currentChannel = channel
                return .none
            case .channelChattingResponse(let chatting):
                state.message = chatting
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    private func fetchChannel(
        channelID: String,
        workspaceID: String
    ) async throws -> ChannelResponse {
        // 내가 속한 채널 조회
        async let chennel = channelClient.fetchChannel(channelID, workspaceID)
        return try await chennel
    }
    
    private func fetchChannelChatting(
        channelID: String,
        workspaceID: String,
        cursorDate: String) async throws
    -> [ChattingPresentModel] {
        
        async let chattingList = channelClient.fetchChattingList(
            channelID,
            workspaceID,
            cursorDate
        )
        return try await chattingList.map { $0.toChattingPresentModel()}
    }
}
