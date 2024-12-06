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
    @Dependency(\.userClient) var userClient
    
    @ObservableState
    struct State {
//        var opponentID: String
//        var workspaceID: String
        
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
                    do {
                        if let dbDMsRoom = try dbClient.fetchDMRoom(
                            state.dmsRoomResponse.id
                        ) {
                            
                        } else {
                            print("DB에 DMsRoom없음")
                            
                        }
                    }
                }
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
            case .sendButtonTap:
                return .run { [state = state] send in
                    do {
                        guard let images = state.selectedImages, !images.isEmpty else {
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
//                                await send(.saveSendedDM(result))
                            } catch {
                                print("Realm 추가 실패")
                            }
                            return
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
//                            await send(.saveSendedDM(result))
                        } catch {
                            print("Realm 추가 실패")
                        }
                        
                        
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
