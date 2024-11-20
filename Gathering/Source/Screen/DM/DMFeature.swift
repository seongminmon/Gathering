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
        
        // 워크 스페이스 멤버 조회는 2가지 방법이 있음
        // (1) 내가 속한 특정 워크스페이스 정보 조회
        // (2) 워크스페이스 멤버 조회
        // (1) 선택
        var workspaceMembers: [Member] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // MARK: - 유저 Action
        case task
        case inviteMemberButtonTap
        
        // MARK: - 내부 Action
        case myWorkspaceList([WorkspaceResponse])
        case myProfileResponse(MyProfileResponse)
        case fetchWorkspaceMembers
        case workspaceMember([Member])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .task:
                return .run { send in
                    // 내가 속한 워크스페이스 리스트 조회
                    async let workspaces = workspaceClient.fetchMyWorkspaceList()
                    // 내 프로필 조회
                    async let profile = userClient.fetchMyProfile()
                    
                    do {
                        let (workspaceResult, profileResult) = try await (workspaces, profile)
                        await send(.myWorkspaceList(workspaceResult))
                        await send(.myProfileResponse(profileResult))
                        // workspaceList를 받은 후에 멤버 조회 액션 전송
                        await send(.fetchWorkspaceMembers)
                    } catch {}
                    
//                    do {
//                    // 내가 속한 워크스페이스 리스트 조회
//                        let result = try await workspaceClient.fetchMyWorkspaceList()
//                        await send(.myWorkspaceList(result))
//                    } catch {}
//                    
//                    // 내 프로필 조회
//                    do {
//                        print(2)
//                        let result = try await userClient.fetchMyProfile()
//                        await send(.myProfileResponse(result))
//                    } catch {}
                    
                    // 내가 속한 특정 워크스페이스 정보 조회
//                    if let workspaceID = state.currentWorkspace?.workspace_id {
//                        print(3)
//                        do {
//                            let result = try await workspaceClient.fetchWorkspaceInfo(workspaceID)
//                            await send(.workspaceMember(
//                                result.workspaceMembers?.map { $0.toMember } ?? []
//                            ))
//                        } catch {}
//                    }
                }
                
            case .myWorkspaceList(let result):
                state.myWorkspaceList = result
                state.currentWorkspace = result.first
                return .none
                
            case .myProfileResponse(let result):
                state.myProfile = result
                return .none
                
            case .fetchWorkspaceMembers:
                // 내가 속한 특정 워크스페이스 정보 조회
                guard let workspaceID = state.currentWorkspace?.workspace_id else {
                    print("워크스페이스 ID 없음")
                    return .none
                }
                
                return .run { send in
                    do {
                        let result = try await workspaceClient.fetchWorkspaceInfo(workspaceID)
                        await send(.workspaceMember(
                            result.workspaceMembers?.map { $0.toMember } ?? []
                        ))
                    } catch {
                        print("Error fetching workspace members:", error)
                    }
                }
                
            case .workspaceMember(let result):
                state.workspaceMembers = result
                print("워크 스페이스 멤버 조회")
                print(state.workspaceMembers)
                return .none
                
            case .inviteMemberButtonTap:
                print("팀원 초대 버튼 탭")
                return .none
            }
        }
        
    }
}
