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
    @Dependency(\.dmsClient) var dmsClient
    
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
        // (1) 방법 선택
        var workspaceMembers: [Member] = []
        
        var dmRoomList: [DMsRoom] = []
        
        // 멤버 초대
        var inviteMemberViewPresented = false
        var email = ""
        var inviteButtonValid = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // MARK: - 유저 Action
        case task
        case inviteMemberSheetButtonTap
        case inviteMemberButtonTap
        
        // MARK: - 내부 Action
        case myWorkspaceList([WorkspaceResponse])
        case myProfileResponse(MyProfileResponse)
        case fetchWorkspaceMembers
        case workspaceMember([Member])
        case fetchDMRooms
        case dmRoomsResponse([DMsRoom])
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
                        await send(.fetchDMRooms)
                    } catch {}
                }
                
            case .myWorkspaceList(let result):
                state.myWorkspaceList = result
                // 임의로 첫번째 워크스페이스로 선택
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
                    } catch {}
                }
                
            case .fetchDMRooms:
                guard let workspaceID = state.currentWorkspace?.workspace_id else {
                    return .none
                }
                
                return .run { send in
                    do {
                        let result = try await dmsClient.fetchDMSList(workspaceID)
                        await send(.dmRoomsResponse(result.map { $0.toDmsRoom }))
                    } catch {}
                }
                
            case .workspaceMember(let result):
                // 본인을 제외한 다른 멤버들만 보여주기
                state.workspaceMembers = result.filter { $0.id != UserDefaultsManager.userID }
                return .none
                
            case .dmRoomsResponse(let result):
                state.dmRoomList = result
                print("dmRoom 리스트 통신")
                print(state.dmRoomList)
                return .none
                
            case .inviteMemberSheetButtonTap:
                print("팀원 초대 버튼 탭")
                state.inviteMemberViewPresented = true
                return .none
                
            case .inviteMemberButtonTap:
                print("초대 보내기 버튼 탭")
                return .none
            }
        }
        
    }
}
