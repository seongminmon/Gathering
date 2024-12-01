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
    
    @ObservableState
    struct State {
        var channelName: String = ""
        var channelDescription: String = ""
        var isValid: Bool {
            !channelName.isEmpty
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
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
                        let result = try await channelClient.createChannel(
                            UserDefaultsManager.workspaceID,
                            ChannelRequest(name: state.channelName,
                                           description: state.channelDescription,
                                           image: nil))
                        Notification.postToast(title: "채널이 생성되었습니다")
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
            }
        }
    }
}
