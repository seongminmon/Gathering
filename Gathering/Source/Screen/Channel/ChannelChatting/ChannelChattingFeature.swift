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
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        // 이전 화면에서 전달
        var channelID: String
        
        var socket: SocketIOManager<ChannelChattingResponse>?
        
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
        case binding(BindingAction<State>)
        
        // MARK: - 유저 액션
        case task
        case sendButtonTap
        case imageDeleteButtonTap(UIImage)
        case settingButtonTap(ChannelResponse?)
        case profileButtonTap(Member)
        case backButtonTap
        
        // MARK: - 내부 액션
        case currentChannelResponse(ChannelResponse?)
        case updateChannelChattings([ChattingPresentModel])
        case fetchDBChatting(ChannelResponse?)
        case sendChannelChattingMessage
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                // MARK: - Binding
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !(state.selectedImages?.isEmpty ?? true)
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .binding:
                return .none
                
                // MARK: - 유저 액션
            case .task:
                // 소켓 연결
                state.socket = SocketIOManager(
                    id: state.channelID,
                    socketInfo: .channel
                ) { result in
                    switch result {
                    case .success(let data):
                        // TODO: - DB 추가 + fetch
                        print("소켓 Data", data)
                    case .failure(let error):
                        print(error)
                    }
                }
                
                // 내가 속한 특정 채널 정보 조회
                return .run { [channelID = state.channelID] send in
                    do {
                        let channel = try await channelClient.fetchChannel(
                            channelID,
                            UserDefaultsManager.workspaceID
                        )
                        await send(.currentChannelResponse(channel))
                        await send(.fetchDBChatting(channel))
                        print("채팅패치 성공")
                    } catch {
                        print("채팅 패치 실패")
                    }
                }
                
            case .settingButtonTap:
                // 홈뷰에서 path 처리
                return .none
                
            case .profileButtonTap:
                // 홈뷰에서 path 처리
                return .none
                
            case .imageDeleteButtonTap(let image):
                guard let index = state.selectedImages?.firstIndex(of: image) else {
                    return .none
                }
                state.selectedImages?.remove(at: index)
                print(state.selectedImages ?? [])
                return .none
                
            case .sendButtonTap:
                return .run { [state = state] send in
                    do {
                        // 메시지 전송 요청
                        guard let channelID = state.currentChannel?.channel_id else { return }
                        let dataList = state.selectedImages?.compactMap {
                            $0.jpegData(compressionQuality: 0.5)
                        }
                        let result = try await channelClient.sendChatting(
                            channelID,
                            UserDefaultsManager.workspaceID,
                            ChattingRequest(content: state.messageText, files: dataList ?? [])
                        )
                        // 메시지 전송 후 초기화
                        await send(.sendChannelChattingMessage)
                        
                        // TODO: - DB 저장 + 업데이트된 채팅 불러오기는 소켓 데이터에서 처리하기
                        // DB 저장 및 파일 처리
                        await saveMessageToDB(channelID: channelID, result: result)
                        
                        // 업데이트된 채팅 불러오기
                        if let updatedChats = fetchUpdatedChannelChats(channelID: channelID) {
                            await send(.updateChannelChattings(updatedChats))
                        }
                    } catch {
                        print("메세지 전송 실패")
                        Notification.postToast(title: "메세지 전송을 실패했습니다.")
                    }
                }
                
            case .backButtonTap:
                state.socket = nil
                return .run { send in
                    await dismiss()
                }
                
                // TODO: - onDisappear 시점에 소켓 Deinit 하도록 만들기
//            case .onDisappear:
//                print("채널 채팅 리듀서 - onDisappear")
//                state.socket = nil
//                return .none
                
                // MARK: - 내부 액션
            case .currentChannelResponse(let channel):
                state.currentChannel = channel
                return .none
                
            case .fetchDBChatting(let channel):
                return .run { send in
                    guard let channel else { return }
                    // 채널 저장 또는 업데이트
                    saveOrUpdateChannel(channel: channel)
                    // 새 채팅 불러오기 및 저장
                    do {
                        let updatedChats = try await fetchAndSaveNewChats(channel: channel)
                        await send(.updateChannelChattings(updatedChats))
                    } catch {
                        print("채팅 불러오기, 저장 실패: \(error)")
                    }
                }
                
            case .updateChannelChattings(let chatting):
                state.message = chatting
                return .none
                
            case .sendChannelChattingMessage:
                state.messageText = ""
                state.selectedImages = []
                state.messageButtonValid = false
                return .none
            }
        }
    }
}

extension ChannelChattingFeature {
    
    private func saveOrUpdateChannel(channel: ChannelResponse) {
        guard let channelMembers = channel.channelMembers else { return }
        let members: [MemberDBModel] = channelMembers.map { $0.toDBModel() }
        
        // TODO: - 멤버 profile 사진 파일 업데이트 (저장 + 삭제)
        
        do {
            if let existingDBChannel = try dbClient.fetchChannel(channel.channel_id) {
                // 기존 채널 업데이트
                try dbClient.updateChannel(existingDBChannel, channel.name, members)
                print("DB 채널 업데이트 성공")
            } else {
                // 새 채널 저장
                let dbChannel = channel.toDBModel(members)
                try dbClient.update(dbChannel)
                print("DB 채널 저장 성공")
            }
        } catch {
            print("DB채널 저장/업데이트 실패: \(error)")
        }
    }
    
    private func fetchAndSaveNewChats(
        channel: ChannelResponse
    ) async throws -> [ChattingPresentModel] {
        guard let dbChannel = try dbClient.fetchChannel(channel.channel_id) else {
            return []
        }
        
        // 기존 채팅 불러오기 (날짜 순 정렬)
        let dbChannelChats = Array(dbChannel.chattings.sorted { $0.createdAt < $1.createdAt })
        print("기존채팅", dbChannelChats)
        
        // 마지막 날짜 이후 채팅 불러오기
        let newChannelChats = try await channelClient.fetchChattingList(
            dbChannel.channelID,
            UserDefaultsManager.workspaceID,
            dbChannelChats.last?.createdAt ?? ""
        )
        print("신규채팅", newChannelChats)
        
        // 불러온 채팅 비동기로 DB에 저장
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
                        print("DB 신규채팅 추가 실패: \(error)")
                    }
                }
                
                // 파일 저장 작업
                for file in chat.files {
                    group.addTask {
                        await ImageFileManager.shared.saveImageFile(filename: file)
                    }
                }
            }
        }
        
        // 업데이트된 채팅 다시 불러오기
        guard let updatedDBChats = try dbClient.fetchChannel(channel.channel_id) else {
            return []
        }
        return Array(updatedDBChats.chattings.sorted { $0.createdAt < $1.createdAt })
            .map { $0.toPresentModel() }
    }
    
    @discardableResult
    private func saveMessageToDB(
        channelID: String,
        result: ChannelChattingResponse
    ) async -> TaskGroup<Void> {
        return await withTaskGroup(of: Void.self) { group in
            // 채팅 저장 작업
            group.addTask {
                do {
                    try dbClient.createChannelChatting(
                        channelID,
                        result.toDBModel(result.user.toDBModel())
                    )
                    print("sendedChat 저장성공")
                } catch {
                    print("sendedChat DB에 추가 실패")
                }
            }
            
            // 파일 저장 작업
            for file in result.files {
                group.addTask {
                    await ImageFileManager.shared
                        .saveImageFile(filename: file)
                }
            }
            
            return group
        }
    }
    
    private func fetchUpdatedChannelChats(
        channelID: String
    ) -> [ChattingPresentModel]? {
        do {
            // 채널 불러오기
            guard let dbChannel = try dbClient.fetchChannel(channelID) else {
                return nil
            }
            
            // 디비에서 기존 채팅 불러오기
            let newDbChannelChats = Array(dbChannel.chattings
                .sorted(byKeyPath: "createdAt", ascending: true))
                .map { $0.toPresentModel() }
            
            print("저장후 다시 불러온 채팅", newDbChannelChats)
            return newDbChannelChats
        } catch {
            print("저장 후 채팅 불러오기 실패")
            return nil
        }
    }
}
