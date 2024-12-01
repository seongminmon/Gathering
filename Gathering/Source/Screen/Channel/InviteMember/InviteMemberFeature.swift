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
                        _ = try await workspaceClient.inviteMember(
                            workspaceID,
                            InviteMemberRequest(email: email)
                        )
                        Notification.postToast(title: "멤버를 성공적으로 초대했습니다")
                        await dismiss()
                    } catch {
                        if let error = error as? ErrorResponse {
                            print(error.errorCode)
                            switch error.errorCode {
                            case "E12":
                                Notification.postToast(title: "이미 소속된 멤버입니다")
                            case "E14":
                                Notification.postToast(title: "초대 권한이 없습니다")
                            default:
                                Notification.postToast(title: "회원 정보를 찾을 수 없습니다")
                            }
                        }
                    }
                }
            }
        }
    }
}
