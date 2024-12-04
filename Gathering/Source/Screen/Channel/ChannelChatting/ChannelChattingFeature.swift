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
        case fetchDBChatting(ChannelResponse?)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
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
                        await send(.fetchDBChatting(channel))
                        print("채팅패치 성공")
                        
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
                return .none
 
            case .channelChattingResponse(let chatting):
                state.message = chatting
                print("채널채팅리스폰스에서~", chatting)
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .fetchDBChatting(let channel):
                return .run { send in
                    guard let channel else { return }
                    
                    let members: [MemberDBModel] = channel.channelMembers?
                        .map { $0.toDBModel() } ?? []
                    print("채널멤버: ", members)
                    
                    // DB에 채널 있는지 탐색
                    do {
                        if let dbChannel = try dbClient.fetchChannel(channel.channel_id){
                            do {
                                try dbClient.updateChannel(dbChannel, channel.name, members)
                                print("DB 채널 업데이트 성공")
                            } catch {
                                print("DB 채널 업데이트 실패")
                            }
                        } else {
                            print("DB에 ,,,채널 없음 ")
                            let dbChannel = channel.toDBModel(members)
                            do {
                                try dbClient.update(dbChannel)
                                print("DB 채널 저장 성공")
                            } catch {
                                print("DB 채널 저장 실패")
                            }
                        }
                        print(channel)
                        // 있으면 DB 채팅 빼고 업데이트
//                        do {
//                            try dbClient.updateChannel(dbChannel, channel.name, members)
//                            print("DB 채널 업데이트 성공")
//                        } catch {
//                            print("DB 채널 업데이트 실패")
//                        }
                        
                    } catch {
                        // 없으면 DB 저장
//                        let dbChannel = channel.toDBModel(members)
//                        do {
//                            try dbClient.update(dbChannel)
//                            print("DB 채널 저장 성공")
//                        } catch {
//                            print("DB 채널 저장 실패")
//                        }
                    }
                    
//                    // DB에 채널 있는지 탐색
//                    do {
//                        if let dbChannel = try dbClient.fetchChannel(channel.channel_id) {
//                            // 있으면 DB 채팅 빼고 업데이트
//                            do {
//                                try dbClient.updateChannel(dbChannel, channel.name, members)
//                                print("DB 채널 업데이트 성공")
//                            } catch {
//                                print("DB 채널 업데이트 실패")
//                            }
//
//                        } else {
//                            // 없으면 DB 저장
//                            let dbChannel = channel.toDBModel(members)
//                            do {
//                                try dbClient.update(dbChannel)
//                                print("DB 채널 저장 성공")
//                            } catch {
//                                print("DB 채널 저장 실패")
//                            }
//                        }
//                                                
//                    } catch {
//                        
//                    }
                    
                    // 채팅들 추가하기
                    // 디비에서 불러오기 -> 마지막 날짜 이후 채팅 불러오기 -> 불러온 채팅 디비에 저장하기 -> 전체채팅디비 다시불러오기
                    do {
                        // 채널 불러오기
                        guard let dbChannel = try dbClient.fetchChannel(
                            channel.channel_id
                        ) else { return }
                        // 디비에서 기존 채팅 불러오기
                        let dbChannelChats = Array(dbChannel.chattings
                            .sorted(byKeyPath: "createdAt", ascending: true))
                        print("기존채팅", dbChannelChats)
                        // 마지막 날짜 이후 채팅 불러오기
                        let newChannelChats = try await channelClient.fetchChattingList(
                            dbChannel.channelID,
                            UserDefaultsManager.workspaceID,
                            dbChannelChats.last?.createdAt ?? ""
                        )
                        print("신규채팅", newChannelChats)
////                        // 불러온 채팅 디비에 저장하기
//                        newChannelChats.forEach { chat in
//                            do {
//                                try dbClient.createChannelChatting(
//                                    channel.channel_id,
//                                    chat.toDBModel(chat.user.toDBModel())
//                                )
//                            } catch {
//                                print("DB 채팅 추가 실패")
//                            }
//                            chat.files.forEach { file in
//                                await ImageFileManager.shared.saveImageFile(filename: file)
//                            }
//                        }
                        await withTaskGroup(of: Void.self) { group in
                            for chat in newChannelChats {
                                // 채팅 저장 작업
                                group.addTask {
                                    do {
                                        try dbClient.createChannelChatting(
                                            channel.channel_id,
                                            chat.toDBModel(chat.user.toDBModel())
                                        )
                                        print("DB 신규채팅 추가 성공")
                                        
                                    } catch {
                                        print("DB 신규채팅 추가 실패")
                                    }
                                }

                                // 파일 저장 작업
//                                for file in chat.files {
//                                    group.addTask {
//                                        await ImageFileManager.shared.saveImageFile(filename: file)
//                                    }
//                                }
                            }
                        }
                        guard let channelUpdatedDBChats = try dbClient
                            .fetchChannel(channel.channel_id) else { return }
                        
                        let udpatedChats = Array(channelUpdatedDBChats.chattings).map {
                            $0.toPresentModel()
                        }
                        await send(.channelChattingResponse(udpatedChats))
                        
                    } catch {
                        
                    }
                    
                }
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
    
    //    private func fetchNewChannelChatting(
    //        channelID: String,
    //        workspaceID: String,
    //        cursorDate: String?) async throws
    //    -> [ChannelChattingResponse] {
    //        async let chattingList = channelClient.fetchChattingList(
    //            channelID,
    //            workspaceID,
    //            cursorDate ?? ""
    //        )
    //        return try await chattingList
    //    }
}
