//
//  DMChattingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct DMChattingFeature {
    
    @Dependency(\.dmsClient) var dmsClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
//        var opponentID: String
//        var workspaceID: String
        
        var socket: SocketIOManager<DMsResponse>?
        
        var dmsRoomResponse: DMsRoom
        var message: [ChattingPresentModel] = []
        
        var messageText = ""
        var selectedImages: [UIImage]? = []
        var scrollViewID = UUID()
        var keyboardHeight: CGFloat = 0
        
        var messageButtonValid = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case task
        case backButtonTap
//        case onDisappear
        case sendButtonTap
        case imageDeleteButtonTap(UIImage)
        case profileButtonTap(Member)
        
        case dmsChattingResponse([ChattingPresentModel])
        case sendDmMessage(DMsResponse)
        case sendMessageError(Error)
        case saveSendedDM(DMsResponse)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .profileButtonTap:
                // homeview와 dmView에서 path로 처리
                return .none
                
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !(state.selectedImages?.isEmpty ?? true)
                || !(state.selectedImages?.isEmpty ?? true)
                return .none
                
            case .task:
                // MARK: - 소켓 테스트
                state.socket = SocketIOManager(
                    id: state.dmsRoomResponse.id,
                    socketInfo: .dm
                ) { result in
                    switch result {
                    case .success(let data):
                        print("DM 소켓 데이터", data)
                    case .failure(let error):
                        print("DM 소켓 error", error)
                    }
                }
                return .none
                /*
                 return .run { [dmsRoomID = state.dmsRoomResponse.id] send in
                 do {
                 // 디비에서 불러오기
                 let dmDBChats = try dbClient.fetchDMChats(dmsRoomID)
                 .map { $0.toResponseModel() }
                 
                 // 마지막 날짜로 이후 채팅 불러오기
                 let dmNewChats = try await fetchNewDMsChatting(
                 workspaceID: UserDefaultsManager.workspaceID,
                 roomID: dmsRoomID,
                 cursorDate: dmDBChats.last?.createdAt)
                 // 불러온 채팅 디비에 저장하기
                 dmNewChats.forEach {
                 do {
                 // MARK: - create에서 update로 변경
                 try dbClient.update($0.toDBModel())
                 } catch {
                 print("Realm 추가 실패")
                 }
                 // TODO: - 파일매니저에 이미지 저장
                 }
                 // 디비 다시 불러오기?
                 let dmUpdatedDBChats = try dbClient.fetchDMChats(dmsRoomID)
                 .map { $0.toResponseModel().toChattingPresentModel()}
                 //                        print(dmUpdatedDBChats.last)
                 await send(.dmsChattingResponse(dmUpdatedDBChats))
                 } catch {
                 print("채팅 패치 실패")
                 }
                 }
                 */
                // TODO: 멀티파트 업로드 수정
                
                // TODO: - 네비게이션 백 제스처 때도 소켓 Deinit 하도록 만들기
            case .backButtonTap:
                state.socket = nil
                return .run { send in
                    await dismiss()
                }
                
//            case .onDisappear:
//                print("DM 채팅 리듀서 - onDisapper")
//                state.socket = nil
//                return .none
                
            case .sendButtonTap:
                return .run { [state = state] send in
                    do {
                        guard let images = state.selectedImages,
                              !images.isEmpty else {
                            let result = try await dmsClient.sendDMMessage(
                                UserDefaultsManager.workspaceID,
                                state.dmsRoomResponse.id,
                                DMRequest(content: state.messageText, files: [])
                            )
                            do {
                                // MARK: - 멤버 잘 찾아서 넣기
                                
                                let member = MemberDBModel()
                                try dbClient.update(result.toDBModel(member))
                                print("sendedDM 저장성공")
                                await send(.saveSendedDM(result))
                            } catch {
                                print("Realm 추가 실패")
                            }
                            return await send(.sendDmMessage(result))
                        }
                        let jpegData = images.map({ value in
                            value.jpegData(compressionQuality: 0.5)!
                        })
                        
                        let result = try await dmsClient.sendDMMessage(
                            UserDefaultsManager.workspaceID,
                            state.dmsRoomResponse.id,
                            DMRequest(
                                content: state.messageText,
                                files: jpegData
                            )
                        )
                        do {
                            // MARK: - 멤버 잘 찾아서 넣기
                            let member = MemberDBModel()
                            try dbClient.update(result.toDBModel(member))
                            print("sendedDM 저장성공")
                            await send(.saveSendedDM(result))
                        } catch {
                            print("Realm 추가 실패")
                        }
                        await send(.sendDmMessage(result))
                        
                    } catch {
                        print("멀티파트 실패 ㅠㅠ ")
                        await send(.sendMessageError(error))
                    }
                }
                
            case .imageDeleteButtonTap(let image):
                guard let index = state.selectedImages?.firstIndex(of: image) else {
                    return .none
                }
                let newImages = state.selectedImages?.remove(at: index)
                print(state.selectedImages)
                return .none
                
            case .sendDmMessage(let result):
                print(result)
                state.messageText = ""
                state.selectedImages = []
                state.messageButtonValid = false
//                state.message.append(result.toChattingPresentModel())
                return .none
                
            case .saveSendedDM(let result):
                return .none
                /*
                return .run { [state = state] send in
                    do {
                        let dmUpdatedDBChats = try dbClient.fetchDMChats(
                            state.dmsRoomResponse.id
                        )
                            .map { $0.toResponseModel().toChattingPresentModel()}
                        await send(.dmsChattingResponse(dmUpdatedDBChats))
                    } catch {
                        print("몰라..")
                    }
                }
                 */

            case .dmsChattingResponse(let dmUpdatedDBChats):
                state.message = dmUpdatedDBChats
                return .none
                
            case .sendMessageError(let error):
                Notification.postToast(title: "메세지 전송 실패")
                print(error)
                return .none
                
            default:
                return .none
            }
        }
    }
    
    private func fetchNewDMsChatting(
        workspaceID: String,
        roomID: String,
        cursorDate: String?
    ) async throws -> [DMsResponse] {
        async let newChats = dmsClient.fetchDMChatHistory(
            workspaceID,
            roomID,
            cursorDate ?? "")
        return try await newChats
    }
}


/*
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
         // 채널 불러오기
         guard let dbChannel = try dbClient.fetchChannel(channel.channel_id) else { return .none }
         // 디비에서 기존 채팅 불러오기
         let dbChannelChats = Array(dbChannel.chattings)
         
         
         // 마지막 날짜 이후 채팅 불러오기
         let newChannelChats = try await channelClient.fetchChattingList(
             dbChannel.channelID,
             UserDefaultsManager.workspaceID,
             dbChannelChats.last?.createdAt ?? ""
         )
//                    let channelNewChats = try await fetchNewChannelChatting(
//                        channelID: channel.channel_id,
//                        workspaceID: UserDefaultsManager.workspaceID,
//                        cursorDate: channelDbChats.last?.createdAt
//                    )
         
         // 불러온 채팅 디비에 저장하기
//                    channelNewChats.forEach { chat in
//                        do {
//                            try dbClient.createChannelChatting(
//                                channel.channel_id,
//                                chat.toDBModel(chat.user.toDBModel())
//                            )
//                        } catch {
//                            print("DB 채팅 추가 실패")
//                        }
//                        chat.files.forEach { file in
//                            ImageFileManager.shared.saveImageFile(filename: file)
//                        }
//                    }
//                    guard let channelUpdatedDBChats = try dbClient
//                        .fetchChannel(channel.channel_id) else { return .none }
//
//                    let udpatedChats = Array(channelUpdatedDBChats.chattings).map {
//                        $0.toPresentModel()
//                    }
//                    await send(.channelChattingResponse(udpatedChats))
     } catch {
         print("DB 채널채팅 불러오기 실패")
     }
   
     // TODO: - 채팅들 추가하기
     // 기존 DB 있을 때 - 채팅 마지막 날짜 기준으로 api 불러오고 DB 추가
     // 기존 DB 없을 때 - 빈날짜로 api 불러오고 DB 추가
     // + 파일매니저
     
     return .none
 */
