//
//  CreateChannelFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct CreateChannelFeature {
    
    @Dependency(\.channelClient) var channelClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {

        var channelName: String = ""
        var channelDescription: String = ""
        var isValid: Bool {
            !channelName.isEmpty
        }
        
        var selectedImage: [UIImage]? = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case saveButtonTapped
        case channelCreated
        
        case deleteImageButtonTapped
        
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .saveButtonTapped:
                guard state.isValid else { return .none }
                return .run { [state = state] send in
                    do {
                        let data =  state.selectedImage?.last?.jpegData(compressionQuality: 0.5)
                        
                        let result = try await channelClient.createChannel(
                            UserDefaultsManager.workspaceID,
                            ChannelRequest(
                                name: state.channelName,
                                description: state.channelDescription,
                                image: data
                            ))
                        
                        // 나를 포함해서 채널 생성
                        let myData = try await userClient.fetchUserProfile(UserDefaultsManager.userID)
                        let dbChannels = result.toDBModel([myData.toDBModel()])
                        try dbClient.update(dbChannels)
                        
                        Notification.postToast(title: "채널이 생성되었습니다")
                        
                        // 뷰 갱신을 위한 액션
                        await send(.channelCreated)
                        
                        await dismiss()
                    } catch {
                        if let errorCode = (error as? ErrorResponse)?.errorCode {
                            switch errorCode {
                            case "E12":
                                Notification.postToast(title: "이미 존재하는 채널 이름 입니다")
                            default:
                                Notification.postToast(title: "채널 생성 실패")
                            }
                        }
                    }
                }
            case .channelCreated:
                return .none
            case .deleteImageButtonTapped:
                state.selectedImage = []
                return .none
            }
        }
    }
}
