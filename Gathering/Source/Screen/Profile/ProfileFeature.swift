//
//  ProfileFeature.swift
//  Gathering
//
//  Created by dopamint on 11/22/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ProfileFeature {
    
    enum ProfileType {
        case me
        case otherUser
    }
    
    @Reducer
    enum Path {
        //        case editContact
        //        case editNickname
    }
    
    @ObservableState
    struct State {
        //        var path = StackState<Path.State>()
        var showAlert = false
        let profileType: ProfileFeature.ProfileType
        var nickname: String
        var email: String
        
        init(profileType: ProfileFeature.ProfileType,
             nickname: String = "",
             email: String = "") {
            self.profileType = profileType
            self.nickname = nickname
            self.email = email
        }
    }
    
    enum Action: BindableAction {
        //        case path(StackAction<Path.State, Path.Action>)
        //        case contactTap
        //        case nicknameTap
        case binding(BindingAction<State>)
        case logoutButtonTap
        case logoutConfirm
        case logoutCancel
//        case dismiss
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .logoutButtonTap:
                state.showAlert = true
                return .none
            case .logoutConfirm:
                state.showAlert = false
                Notification.changeRoot(.fail)
                UserDefaultsManager.removeAll()
                return .none
            case .logoutCancel:
                state.showAlert = false
                return .none
//            case .dismiss:
//                return .run { _ in
//                    await dismiss()
//                }
            }
        }
        //        .forEach(\.path, action: \.path)
    }
}
