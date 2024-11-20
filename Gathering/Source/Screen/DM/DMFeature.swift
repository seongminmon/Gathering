//
//  DMFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct DMFeature {
    
    @Dependency(\.workspaceClient) var workspaceClient
    @Dependency(\.userClient) var userClient
    
    @ObservableState
    struct State {
        // test
        var userList = Dummy.users
        var chattingList = Dummy.users
        var nickname: String = ""
        var itemReponse: [StoreItemResponse] = []
        
        // 워크 스페이스 정보
        var myWorkspaceList: [WorkspaceResponse] = []
        var currentWorkspace: WorkspaceResponse?
        
        // 내 프로필 정보
        var myProfile: MyProfileResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // MARK: - 유저 Action
        case task
        case inviteMemberButtonTap
        
        // MARK: - 내부 Action
        case myWorkspaceList([WorkspaceResponse])
        case myProfileResponse(MyProfileResponse)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .task:
                return .run { send in
                    do {
                        let result = try await workspaceClient.fetchMyWorkspaceList()
                        await send(.myWorkspaceList(result))
                    } catch {
                        //
                    }
                    
                    do {
                        let result = try await userClient.fetchMyProfile()
                        await send(.myProfileResponse(result))
                    } catch {
                        //
                    }
                }
                
            case .myWorkspaceList(let result):
                state.myWorkspaceList = result
                state.currentWorkspace = result.first
                return .none
                
            case .myProfileResponse(let result):
                state.myProfile = result
                return .none
                
            case .inviteMemberButtonTap:
                print("프로필 버튼 탭")
                return .none
            }
        }
        
    }
}
