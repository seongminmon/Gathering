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
    
    @Reducer
    enum Path {
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var message = ChannelDummy.messages
        var messageText = ""
        var selectedImages: [UIImage] = []
        var scrollViewID = UUID()
        var keyboardHeight: CGFloat = 0
        
        var messageButtonValid = false
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case settingButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .settingButtonTap:
                state.path.append(
                    .channelSetting(ChannelSettingFeature.State()))
                return .none
                
            case .path:
                return .none
                
            case .binding(\.messageText):
                state.messageButtonValid = !state.messageText.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .binding(\.selectedImages):
                state.messageButtonValid = !state.selectedImages.isEmpty
                || !state.selectedImages.isEmpty
                return .none
                
            case .binding(_):
                return .none
                
            }
        }
        .forEach(\.path, action: \.path)
    }
}
