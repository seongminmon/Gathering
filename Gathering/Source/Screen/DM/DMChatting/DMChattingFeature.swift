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
    @Dependency(\.realmClient) var realmClient
    
    @Reducer
    enum Path {
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
//        var opponentID: String
//        var workspaceID: String
        var dmsRoomResponse: DMsRoom
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
        
        case dmsChattingResponse([ChattingPresentModel])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {

            case .path:
                return .none
                
            case .binding(_):
                return .none
                
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !state.selectedImages.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .task:
                return .run { [dmsRoomID = state.dmsRoomResponse.id] send in
                    do {
                        // 디비에서 불러오기
                        let dmDBChats = try  realmClient.fetchDMChats(dmsRoomID).map { $0.toResponseModel()}
                        // 마지막 날짜로 이후 채팅 불러오기
                        let dmNewChats = try await fetchNewDMsChatting(
                            workspaceID: UserDefaultsManager.workspaceID,
                            roomID: dmsRoomID,
                            cursorDate: dmDBChats.last?.createdAt)
                        // 불러온 채팅 디비에 저장하기
                        dmNewChats.forEach {
                            do {
                                try realmClient.create($0.toRealmModel())
                            } catch {
                                print("Realm 추가 실패")
                            }
                            // TODO: - 파일매니저에 이미지 저장
                        }
                        // 디비 다시 불러오기?
                        let dmUpdatedDBChats = try  realmClient.fetchDMChats(dmsRoomID).map { $0.toResponseModel().toChattingPresentModel()}
                        await send(.dmsChattingResponse(dmUpdatedDBChats))
                    } catch {
                        print("채팅 패치 실패")
                    }
                }
                
            case .sendButtonTap:
                return .none
                
            case .dmsChattingResponse(let dmUpdatedDBChats):
                state.message = dmUpdatedDBChats
                return .none
            }
        }
        .forEach(\.path, action: \.path)
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
