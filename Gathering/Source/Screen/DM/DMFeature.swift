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
    @Dependency(\.realmClient) var realmClient
    
    @ObservableState
    struct State {
        var isLoading = true
        
        var myWorkspaceList: [WorkspaceResponse] = []
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
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
        case loadingComplete
        case inviteMemberSheetButtonTap
        case inviteMemberButtonTap
        
        // MARK: - 내부 Action
        case myWorkspaceListResponse([WorkspaceResponse])
        case myProfileResponse(MyProfileResponse)

        case workspaceMemberResponse([Member])
        case dmRoomsResponse([DMsRoom])
        
        case inviteMemberResponse(Member)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            // MARK: - Binding
            case .binding(\.email):
                state.inviteButtonValid = !state.email.isEmpty
                return .none
                
            case .binding(\.inviteMemberViewPresented):
                if !state.inviteMemberViewPresented {
                    state.email = ""
                    state.inviteButtonValid = !state.email.isEmpty
                }
                return .none
                
            case .binding:
                return .none
                
            // MARK: - 유저 Action
            case .task:
                state.isLoading = true
                return .run { send in
                    do {
                        let (workspaceResult, profileResult) = try await fetchInitialData()
                        await send(.myWorkspaceListResponse(workspaceResult))
                        await send(.myProfileResponse(profileResult))
                        
                        // 워크스페이스 ID 추출 (첫 번째 워크스페이스 ID 사용)
                        guard let workspaceID = workspaceResult.first?.workspace_id else {
                            Notification.postToast(title: "현재 워크 스페이스 없음")
                            return
                        }
                        
                        let (memberResult, dmRoomResult) = try await fetchWorkspaceDetails(
                            workspaceID: workspaceID
                        )
                        await send(.workspaceMemberResponse(memberResult))
                        await send(.dmRoomsResponse(dmRoomResult))
                        
                        await send(.loadingComplete)
                    } catch {
                        // 에러 처리
                    }
                }
                
            case .inviteMemberSheetButtonTap:
                // 관리자만 멤버 초대 가능
                if state.currentWorkspace?.owner_id == state.myProfile?.userID {
                    state.inviteMemberViewPresented = true
                } else {
                    Notification.postToast(title: "초대 권한이 없습니다")
                }
                return .none
                
            case .inviteMemberButtonTap:
                guard let workspaceID = state.currentWorkspace?.workspace_id else {
                    Notification.postToast(title: "현재 워크 스페이스 없음")
                    return .none
                }
                
                return .run { [email = state.email] send in
                    do {
                        let result = try await workspaceClient.inviteMember(
                            workspaceID,
                            InviteMemberRequest(email: email)
                        )
                        await send(.inviteMemberResponse(result.toMember))
                    } catch {
                        Notification.postToast(title: "초대에 실패했습니다")
                    }
                }
                
            // MARK: - 내부 Action
            case .loadingComplete:
                state.isLoading = false
                return .none
                
            case .myWorkspaceListResponse(let result):
                state.myWorkspaceList = result
                // MARK: - 임의로 첫번째 워크스페이스로 선택
                state.currentWorkspace = result.first
                return .none
                
            case .myProfileResponse(let result):
                state.myProfile = result
                return .none
                
            case .workspaceMemberResponse(let result):
                // 본인 제외 다른 멤버들만 보여주기
                let filteredMembers = result.filter { $0.id != UserDefaultsManager.userID }
                state.workspaceMembers = filteredMembers
                return .none
                
            case .dmRoomsResponse(let result):
                state.dmRoomList = result
                for dmRoom in state.dmRoomList {
                    // realm에서 roomID 기준으로 필터링
                    do {
                        let dmChats = try realmClient.fetchDMChats(dmRoom.id)
                        print("RoomID:", dmRoom.id)
                        print("dmChats:", dmChats)
                    } catch {
                        print("Realm DM 채팅 fetch 실패")
                    }
                }
                return .none
                
            case .inviteMemberResponse(let result):
                Notification.postToast(title: "초대에 성공했습니다")
                // 멤버 추가
                state.workspaceMembers.append(result)
                // 시트 내리기
                state.inviteMemberViewPresented = false
                return .none
            }
        }
        
    }
    
    private func fetchInitialData() async throws -> (
        workspaceList: [WorkspaceResponse],
        profile: MyProfileResponse
    ) {
        // 내가 속한 워크스페이스 리스트 조회
        async let workspaces = workspaceClient.fetchMyWorkspaceList()
        // 내 프로필 조회
        async let profile = userClient.fetchMyProfile()
        return try await (workspaces, profile)
    }
    
    private func fetchWorkspaceDetails(
        workspaceID: String
    ) async throws -> (members: [Member], dmRooms: [DMsRoom]) {
        // 내가 속한 특정 워크스페이스 정보 조회
        // >> 워크 스페이스 멤버 리스트 얻기
        async let members = workspaceClient.fetchWorkspaceMembers(workspaceID)
        // DM 방 리스트 조회
        async let dmRooms = dmsClient.fetchDMSList(workspaceID)
        return try await (members.map { $0.toMember }, dmRooms.map { $0.toDmsRoom })
    }
}
