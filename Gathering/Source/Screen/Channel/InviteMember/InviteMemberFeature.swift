//
//  InviteMemberFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct InviteMemberFeature {
    
    @Dependency(\.workspaceClient) var workspaceClient
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        var email: String = ""
        var inviteButtonValid = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case inviteMemberButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.email):
                state.inviteButtonValid = !state.email.isEmpty
                return .none
            case .binding:
                return .none
            case .inviteMemberButtonTap:
                return .run { [email = state.email] send in
                    do {
                        let workspaceID = UserDefaultsManager.workspaceID
                        let result = try await workspaceClient.inviteMember(
                            workspaceID,
                            InviteMemberRequest(email: email)
                        )
                        await dismiss()
                    } catch {
                        Notification.postToast(title: "초대에 실패했습니다")
                    }
                }
            }
        }
    }
}
