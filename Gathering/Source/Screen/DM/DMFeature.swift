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
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // MARK: - 유저 Action
        case task
        case profileButtonTap
        
        // MARK: - 내부 Action
        case myWorkspaceList([WorkspaceResponse])
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
                }
                
            case .myWorkspaceList(let result):
                state.myWorkspaceList = result
                state.currentWorkspace = result.first
                print("현재 워크스페이스")
                print(state.currentWorkspace)
                return .none
                
            case .profileButtonTap:
                return .none
            }
        }
        
    }
}
