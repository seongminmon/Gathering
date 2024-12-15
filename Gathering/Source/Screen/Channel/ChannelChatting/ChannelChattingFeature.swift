//
//  ChannelChattingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture
import _PhotosUI_SwiftUI

@Reducer
struct ChannelChattingFeature {
    
    @Dependency(\.channelClient) var channelClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        // 이전 화면에서 전달
        var channelID: String
        
        var socketManager: SocketIOManager<ChannelChattingResponse>?
        
        // 특정 채널 조회 결과값 (멤버 포함)
        var currentChannel: ChannelResponse?
        
        var message: [ChattingPresentModel] = []
        
        var messageText = ""
        var selectedImages: [UIImage]? = []
        var scrollViewID = UUID()
        var keyboardHeight: CGFloat = 0
        
        var messageButtonValid = false
        // var isTextFieldFocused = false 
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // MARK: - 유저 액션
        case task
//        case onDisappear
        case sendButtonTap
        case imageDeleteButtonTap(UIImage)
        case settingButtonTap(ChannelResponse?)
        case profileButtonTap(Member)
        case backButtonTap
        
        // MARK: - 내부 액션
        case connectSocket
        case updateSocketManager(SocketIOManager<ChannelChattingResponse>?)
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
                return .run { [state = state] send in
                    // 소켓 연결
                    if state.socketManager == nil {
                        await send(.connectSocket)
                    }
                    
                    // 내가 속한 특정 채널 정보 조회
                    do {
                        let channel = try await channelClient.fetchChannel(
                            state.channelID,
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
                        _ = try await channelClient.sendChatting(
                            channelID,
                            UserDefaultsManager.workspaceID,
                            ChattingRequest(content: state.messageText, files: dataList ?? [])
                        )
                        // 메시지 전송 후 초기화
                        await send(.sendChannelChattingMessage)
                    } catch {
                        print("메세지 전송 실패")
                        Notification.postToast(title: "메세지 전송을 실패했습니다.")
                    }
                }
                
            case .backButtonTap:
                return .run { send in
                    await send(.updateSocketManager(nil))
                    await dismiss()
                }
                
//            case .onDisappear:
//                // TODO: - onDisappear 시점에 소켓 Deinit 하도록 만들기
//                print("채널 채팅 리듀서 - onDisappear")
//                state.socketManager = nil
//                return .none
                
                // MARK: - 내부 액션
            case .currentChannelResponse(let channel):
                state.currentChannel = channel
                return .none
                
            case .fetchDBChatting(let channel):
                return .run { send in
                    guard let channel else { return }
                    // 채널 저장 또는 업데이트
                    await saveOrUpdateChannel(channel: channel)
                    // 새 채팅 불러오기 및 저장
                    do {
                        let updatedChats = try await fetchAndSaveNewChats(channel: channel)
                        await send(.updateChannelChattings(updatedChats))
                    } catch {
                        print("채팅 불러오기, 저장 실패: \(error)")
                    }
                }
                
            case .connectSocket:
                return .run { [channelID = state.channelID] send in
                    // 소켓 연결
                    let socketManager = SocketIOManager<ChannelChattingResponse>(
                        id: channelID,
                        socketInfo: .channel
                    )
                    
                    // 상태에 소켓 매니저 할당
                    await send(.updateSocketManager(socketManager))
                    
                    // 소켓 이벤트를 비동기적으로 처리
                    for try await result in socketManager {
                        switch result {
                        case .success(let data):
                            // DB 저장
                            await saveMessageToDB(channelID: channelID, chattingResponse: data)
                            // 업데이트된 채팅 불러오기
                            let updatedChats = fetchChannelChats(channelID: channelID)
                                .map { $0.toPresentModel() }
                            // 상태 업데이트 액션 전송
                            await send(.updateChannelChattings(updatedChats))
                        case .failure(let error):
                            print("소켓 데이터 받기 실패: \(error)")
                            Notification.postToast(title: "소켓 데이터 받기 실패")
                        }
                    }
                }
                
            case .updateSocketManager(let socketManager):
                state.socketManager = socketManager
                return .none
                
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
    
    /// DB에서 채널 채팅 가져와서 정렬 하는 메서드
    private func fetchChannelChats(channelID: String) -> [ChannelChattingDBModel] {
        do {
            let updatedDBChats = try dbClient.fetchChannel(channelID)
            return Array(updatedDBChats?.chattings.sorted { $0.createdAt < $1.createdAt } ?? [])
        } catch {
            print("DB 채팅 불러오기 실패")
            return []
        }
    }
    
    /// 채팅을 DB + 파일매니저에 추가하는 메서드
    private func saveMessageToDB(
        channelID: String,
        chattingResponse: ChannelChattingResponse
    ) async {
        // 채팅 저장
        do {
            try dbClient.createChannelChatting(
                channelID,
                chattingResponse.toDBModel(chattingResponse.user.toDBModel())
            )
            print("채널 채팅 DB에 추가 성공")
        } catch {
            print("채널 채팅 DB에 추가 실패")
        }
        // 파일 저장
        for file in chattingResponse.files {
            await ImageFileManager.shared.saveImageFile(filename: file)
        }
    }
    private func checkUpdatedMemeberProfile(userID: String) async {
        do {
            let dbProfile = try dbClient.fetchMember(userID)?.profileImage
            let currentProfile = try await userClient.fetchUserProfile(userID)
            
            guard let dbProfileImage = dbProfile else {
                guard let currentProfileImage = currentProfile.profileImage else {
                    return
                }
                // 프로필이미지 저장
                await ImageFileManager.shared
                    .saveImageFile(filename: currentProfileImage)
                return
            }
            
            if dbProfileImage != currentProfile.profileImage {
               ImageFileManager.shared.deleteImageFile(filename: dbProfileImage)
                guard let currentProfileImage = currentProfile.profileImage else {
                    return
                }
                // 프로필이미지 저장
                await ImageFileManager.shared
                    .saveImageFile(filename: currentProfileImage)
                 
                try dbClient.update(currentProfile.toDBModel())
            }
         
        } catch {
            print("프로필불러오기 실패")
        }
    }

    private func saveOrUpdateChannel(channel: ChannelResponse) async {
        guard let channelMembers = channel.channelMembers else { return }
        let members: [MemberDBModel] = channelMembers.map { $0.toDBModel() }
        
        // TODO: - 멤버 profile 사진 파일 업데이트 (저장 + 삭제)
        for member in members {
            await checkUpdatedMemeberProfile(userID: member.userID)
        }
        
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
        // 기존 채팅 불러오기 (날짜 순 정렬)
        let dbChannelChats = fetchChannelChats(channelID: channel.channel_id)
        print("기존채팅", dbChannelChats)
        
        // 마지막 날짜 이후 채팅 API를 통해 불러오기
        let newChannelChats = try await channelClient.fetchChattingList(
            channel.channel_id,
            UserDefaultsManager.workspaceID,
            dbChannelChats.last?.createdAt ?? ""
        )
        print("신규채팅", newChannelChats)
        
        // TODO: - 비교 필요
        // (1) 불러온 채팅 DB에 저장
        for chat in newChannelChats {
            await saveMessageToDB(channelID: chat.channel_id, chattingResponse: chat)
        }
        
        // (2) 불러온 채팅 비동기로 DB에 저장
//        await withTaskGroup(of: Void.self) { group in
//            for chat in newChannelChats {
//                await saveMessageToDB(channelID: chat.channel_id, chattingResponse: chat)
//            }
//        }
        
        // 업데이트된 채팅 다시 불러오기
        return fetchChannelChats(channelID: channel.channel_id).map { $0.toPresentModel() }
    }
}
