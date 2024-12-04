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
    
    // TODO: - 진입 시 채널 DB 저장(or 갱신)하기
    // TODO: - 채널 채팅 DB 저장
    @Dependency(\.channelClient) var channelClient
    @Dependency(\.dbClient) var dbClient
    
    @Reducer
    enum Destination {
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        
        // 이전 화면에서 전달
        var channelID: String
        
        // 특정 채널 조회 결과값 (멤버 포함)
        var currentChannel: ChannelResponse?
        
        var message: [ChattingPresentModel] = []
        
        var messageText = ""
        var selectedImages: [UIImage]? = []
        var scrollViewID = UUID()
        var keyboardHeight: CGFloat = 0
        
        var messageButtonValid = false
    }
    
    enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        
        case sendButtonTap
        case settingButtonTap(ChannelResponse?)
        
        case task
        case currentChannelResponse(ChannelResponse?)
        case channelChattingResponse([ChattingPresentModel])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !(state.selectedImages?.isEmpty ?? true)
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .settingButtonTap:
                // 홈뷰에서 path 처리
                return .none
           
            case .task:
                return .run { [channelID = state.channelID] send in
                    let workspaceID = UserDefaultsManager.workspaceID
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
                        print(message)
                        await send(.channelChattingResponse(message))
                    } catch {
                        print("채팅 패치 실패")
                    }
                }
            case .sendButtonTap:
                print("전송버튼 클릭")
                state.messageText = ""
                state.selectedImages = []
                state.messageButtonValid = false
                
                return .none
                
            case .currentChannelResponse(let channel):
                state.currentChannel = channel
                
                guard let channel else { return .none }
                let members: [MemberDBModel] = channel.channelMembers?.map { $0.toDBModel() } ?? []
                
                // DB에 채널 있는지 탐색
                do {
                    guard let dbChannel = try dbClient.fetchChannel(channel.channel_id) else {
                        return .none
                    }
                    print(channel)
                    // 있으면 DB 채팅 빼고 업데이트
                    do {
                        try dbClient.updateChannel(dbChannel, channel.name, members)
                        print("DB 채널 업데이트 성공")
                    } catch {
                        print("DB 채널 업데이트 실패")
                    }
                    
                } catch {
                    // 없으면 DB 저장
                    let dbChannel = channel.toDBModel(members)
                    do {
                        try dbClient.update(dbChannel)
                        print("DB 채널 저장 성공")
                    } catch {
                        print("DB 채널 저장 실패")
                    }
                }
                
                // 채팅들 추가하기
                // 디비에서 불러오기 -> 마지막 날짜 이후 채팅 불러오기 -> 불러온 채팅 디비에 저장하기 -> 전체채팅디비 다시불러오기
                do {
                    let dbChannel = try dbClient.fetchChannel(channel.channel_id)
                    // 디비에서 불러오기
                    let channelDbChats = Array(dbChannel.chattings)
                    
                    // 마지막 날짜 이후 채팅 불러오기
                    let channelNewChats = try await fetchNewChannelChatting(
                        channelID: channel.channel_id,
                        workspaceID: UserDefaultsManager.workspaceID,
                        cursorDate: String?
                        ////////////s너무졸려너ㅜ졸려.......
                    )
                    
                    // 불러온 채팅 디비에 저장하기
                    channelNewchats.forEach { chat in
                        do {
                            try dbClient.createChannelChatting(channel.channel_id, )
                        }
                    }
                    
                    
                } catch {
                    print("DB 채널채팅 불러오기 실패")
                }
              
                // TODO: - 채팅들 추가하기
                // 기존 DB 있을 때 - 채팅 마지막 날짜 기준으로 api 불러오고 DB 추가
                // 기존 DB 없을 때 - 빈날짜로 api 불러오고 DB 추가
                // + 파일매니저
                
                return .none
                
            case .channelChattingResponse(let chatting):
                state.message = chatting
                return .none
            case .destination:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    private func fetchChannel(
        channelID: String,
        workspaceID: String
    ) async throws -> ChannelResponse {
        // 내가 속한 채널 조회
        async let chennal = channelClient.fetchChannel(channelID, workspaceID)
        return try await chennal
    }
    
    private func fetchNewChannelChatting(
        channelID: String,
        workspaceID: String,
        cursorDate: String?) async throws
    -> [ChannelChattingResponse] {
        async let chattingList = channelClient.fetchChattingList(
            channelID,
            workspaceID,
            cursorDate
        )
        return try await chattingList.map { $0.toPresentModel() }
    }
}
