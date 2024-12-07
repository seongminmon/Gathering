//
//  DMChattingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture
import RealmSwift

@Reducer
struct DMChattingFeature {
    
    @Dependency(\.dmsClient) var dmsClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.userClient) var userClient
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
        
        case fetchDBChatting(DMsResponse)
        case sendDmMessage
        case savedDBChattingResponse([ChattingPresentModel])
        case sendMessageError(Error)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .profileButtonTap(let user):
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
                return .run { [state = state] send in
                    // DMRoom 확인, 저장/업데이트
                    do {
                        let opponentInfo = state.dmsRoomResponse.user.toDBModel()
                        let myInfo = try await userClient.fetchMyProfile().toDBModel()
                        let members: [MemberDBModel] = [opponentInfo, myInfo]
                        
                        if let dbDMsRoom = try dbClient.fetchDMRoom(state.dmsRoomResponse.id) {
                            do {
                                try dbClient.updateDMRoom(dbDMsRoom, members)
                                print("DB DMRoom 업데이트 성공")
                            } catch {
                                print("DB DMRoom 업데이트 실패")
                            }
                        } else {
                            print("DB에 DMsRoom없음")
                            do {
                                let dmsRoom = state.dmsRoomResponse.toDBModel(members)
                                try dbClient.update(dmsRoom)
                                print("DB DMsRoom 저장 성공")
                            } catch {
                                print("DB DMsRoom 저장 실패")
                            }
                            
                        }
                    } catch {
                        print("DB DmRoom 저장/업데이트 실패")
                    }
                    
                   // 채팅 추가하기
                    do {
                        // 채널 불러오기
                        guard let dbDMsRoom = try dbClient.fetchDMRoom(
                            state.dmsRoomResponse.id
                        ) else { return }
                        
                        // 디비에서 기존 채팅 불러오기
                        let dbDMsChats = Array(dbDMsRoom.chattings
                            .sorted(byKeyPath: "createdAt", ascending: true))
                        print("기존채팅", dbDMsChats)
                        
                        // 마지막 날짜 이후 채팅 불러오기
                        let newDMsChats = try await dmsClient.fetchDMChatHistory(
                            UserDefaultsManager.workspaceID,
                            dbDMsRoom.roomID,
                            dbDMsChats.last?.createdAt ?? ""
                        )
                       
                        print("신규채팅", newDMsChats)
                        
                        // 불러온 채팅 디비에 저장하기
                        await withTaskGroup(of: Void.self) { group in
                            for chat in newDMsChats {
                                // 채팅 저장 작업
                                group.addTask {
                                    do {
                                        try dbClient.createDMChatting(
                                            state.dmsRoomResponse.id,
                                            chat.toDBModel(chat.user.toDBModel())
                                        )
                                        print("DB 신규채팅 추가 성공")
                                    } catch {
                                        print("DB 신규채팅 추가 실패")
                                    }
                                }
                                
                                // 파일 저장 작업
                                for file in chat.files {
                                    group.addTask {
                                        await ImageFileManager.shared
                                            .saveImageFile(filename: file)
                                    }
                                }
                            }
                        }
                        
                        guard let updatedDbDmsRoom = try dbClient
                            .fetchDMRoom(state.dmsRoomResponse.id) else { return }
                        
                        let updatedChats = Array(updatedDbDmsRoom.chattings).map {
                            $0.toPresentModel()
                        }
                        await send(.savedDBChattingResponse(updatedChats))

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
                        
                    } catch {
                        print("채팅 불러오기, 저장 실패")
                    }
                }

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
                            await withTaskGroup(of: Void.self) { group in
                                // 채팅 저장 작업
                                group.addTask {
                                    do {
                                        try dbClient.createDMChatting(
                                            state.dmsRoomResponse.id,
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
                            }
                            do {
                                // 채널 불러오기
                                guard let dbDMsRoom = try dbClient.fetchDMRoom(
                                    state.dmsRoomResponse.id
                                ) else { return }
                                // 디비에서 기존 채팅 불러오기
                                let newDbDMsChats = Array(dbDMsRoom.chattings
                                    .sorted(byKeyPath: "createdAt", ascending: true))
                                    .map { $0.toPresentModel() }
                                print("저장후 다시 불러온 채팅", newDbDMsChats)
                                await send(.savedDBChattingResponse(newDbDMsChats))
                            } catch {
                                print("저장 후 채팅 불러오기 실패")
                            }
                            await send(.sendDmMessage)
                            return
                        }
                        // 이미지 있는 경우
                        // TODO: data로 변환방법 생각해보기
                        let jpegData = images.map({ value in
                            value.jpegData(compressionQuality: 0.5)!
                        })
                        
                        let result = try await dmsClient.sendDMMessage(
                            UserDefaultsManager.workspaceID,
                            state.dmsRoomResponse.id,
                            DMRequest(content: state.messageText, files: jpegData)
                        )
                        do {
                            try dbClient.createDMChatting(
                                state.dmsRoomResponse.id,
                                result.toDBModel(result.user.toDBModel())
                                )
                            print("sendedDM DB 저장성공")
                        } catch {
                            print("DB 추가 실패")
                        }
                        
                        do {
                            // 채널 불러오기
                            guard let dbDMsRoom = try dbClient.fetchDMRoom(
                                state.dmsRoomResponse.id
                            ) else { return }
                            // 디비에서 기존 채팅 불러오기
                            let newDbDMsChats = Array(dbDMsRoom.chattings
                                .sorted(byKeyPath: "createdAt", ascending: true))
                                .map { $0.toPresentModel() }
                            print("저장후 다시 불러온 채팅", newDbDMsChats)
                            await send(.savedDBChattingResponse(newDbDMsChats))
                        } catch {
                            print("저장 후 채팅 불러오기 실패")
                        }
                        await send(.sendDmMessage)
                    } catch {
                        print("멀티파트 실패 ㅠㅠ ")
                        Notification.postToast(title: "메세지 전송을 실패했습니다.")
                    }
                }
                
            case .imageDeleteButtonTap(let image):
                guard let index = state.selectedImages?.firstIndex(of: image) else {
                    return .none
                }
                let newImages = state.selectedImages?.remove(at: index)
                print(state.selectedImages)
                return .none
                
            case .sendDmMessage:
                state.messageText = ""
                state.selectedImages = []
                state.messageButtonValid = false
                return .none
                
            case .savedDBChattingResponse(let updatedDBChats):
                state.message = updatedDBChats
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
}
