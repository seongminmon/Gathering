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
    
    @Reducer
    enum Path {
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
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {

            case .path:
                return .none
            case .binding(_):
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
}
