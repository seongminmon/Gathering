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
    
    @Dependency(\.dbClient) var dbClient
    
    enum ProfileType {
        case me
        case otherUser
    }
    
    @ObservableState
    struct State {
        var showAlert = false
        let profileType: ProfileFeature.ProfileType
        var nickname: String
        var email: String
        var profileImage: String
        // 새로 추가할 상태들
        var sesacCoin: Int = 130  // 임시값
        
        init(profileType: ProfileFeature.ProfileType,
             nickname: String = "",
             email: String = "",
             profileImage: String = "") {
            self.profileType = profileType
            self.nickname = nickname
            self.email = email
            self.profileImage = profileImage
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logoutButtonTap
        case logoutConfirm
        case logoutCancel
        // 새로 추가할 액션들
        case chargeSesacCoinTap
        case phoneNumberTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
                do {
                    try dbClient.removeAll()
                } catch {}
                ImageFileManager.shared.deleteAllImages()
                return .none
                
            case .logoutCancel:
                state.showAlert = false
                return .none
                
            case .chargeSesacCoinTap:
                // 충전 로직 구현
                return .none
                
            case .phoneNumberTap:
                // 전화번호 수정 로직 구현
                return .none
            }
        }
    }
}
