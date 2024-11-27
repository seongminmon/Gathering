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
//                        await send(.createChannel)
                        let result = try await channelClient.createChannel(
                            "sd", 
                            ChannelRequest(name: state.channelName,
                                           description: "",
                                           image: nil))
                        print(result)
                        await self.dismiss()
                    } catch {
                        let errorCode = (error as? ErrorResponse)?.errorCode
                        if errorCode == "E13" {
                            Notification.postToast(title: "이미 존재하는 채널이름 입니다")
                        }
                    }
                    
                }
//            case .createChannel:
//                
//                return .none
            }
        }
    }
}
