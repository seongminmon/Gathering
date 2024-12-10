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
    @Dependency(\.dbClient) var dbClient
    
    @Reducer
    enum Path {
        case profile(ProfileFeature)
        case dmChatting(DMChattingFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var isLoading = true
        
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
        var workspaceMembers: [Member] = []
        var dmRoomList: [DMsRoom] = []
        
        // DMRoom 별로 마지막 채팅 + UnReadCount
        var dmLastChattings = [DMsRoom: ChattingPresentModel]()
        var dmUnreads = [DMsRoom: UnreadDMsResponse]()
        
        // 멤버 초대
        var inviteMemberViewPresented = false
        var email = ""
        var inviteButtonValid = false
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        
        // MARK: - 유저 Action
        case task
        case loadingComplete
        case inviteMemberSheetButtonTap
        case inviteMemberButtonTap
        case userCellTap(Member)
        case dmCellTap(DMsRoom)
        
        // MARK: - 내부 Action
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        
        case workspaceMemberResponse([Member])
        case dmRoomsResponse([DMsRoom])
        
        case dmChatsResponse(DMsRoom, [DMsResponse])
        case unreadCountResponse(DMsRoom, UnreadDMsResponse)
        
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
                        await send(.myProfileResponse(profileResult))
                        
                        if let filtered = workspaceResult.filter(
                            { $0.workspace_id == UserDefaultsManager.workspaceID }
                        ).first {
                            // UserDefaults에 있는 워크스페이스 선택
                            await send(.myWorkspaceResponse(filtered))
                        } else {
                            // UserDefaults에 없으면 첫번째 워크스페이스 선택
                            guard let workspaceID = workspaceResult.first?.workspace_id else {
                                Notification.postToast(title: "현재 워크 스페이스 없음")
                                return
                            }
                            UserDefaultsManager.recentWorkspaceID(workspaceID)
                            await send(.myWorkspaceResponse(workspaceResult.first))
                        }
                        
                        let (memberResult, dmRoomResult) = try await fetchWorkspaceDetails(
                            workspaceID: UserDefaultsManager.workspaceID
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
                        await send(.inviteMemberResponse(result.toPresentModel()))
                    } catch {
                        Notification.postToast(title: "초대에 실패했습니다")
                    }
                }
                
            case .userCellTap(let user):
                return .run { send in
                    let result = try await dmsClient.fetchOrCreateDM(
                        UserDefaultsManager.workspaceID,
                        DMOpponentRequest(opponentID: user.id)
                    )
                    await send(.dmCellTap(result.toPresentModel()))
                }
                
            case .dmCellTap(let dmRoom):
                state.path.append(.dmChatting(DMChattingFeature.State(
                    dmsRoomResponse: dmRoom
                )))
                return .none
                
                // MARK: - 내부 Action
            case .loadingComplete:
                state.isLoading = false
                return .none
                
            case .myWorkspaceResponse(let workspace):
                state.currentWorkspace = workspace
                return .none
                
            case .myProfileResponse(let result):
                state.myProfile = result
                return .none
                
            case .workspaceMemberResponse(let result):
                // 본인 제외 다른 멤버들만 보여주기
                let filteredMembers = result.filter { $0.id != UserDefaultsManager.userID }
                state.workspaceMembers = filteredMembers
                return .none
                
            case .dmRoomsResponse(let dmRooms):
                state.dmRoomList = dmRooms
                
                // DM Room List 구한 뒤 모든 DM Room에 대한 Effect를 병렬로 실행
                return .merge(dmRooms.map { dmRoom in
                    return .run { send in
                        do {
                            let dbDMRoom = try dbClient.fetchDMRoom(dmRoom.id)
                            let dbChattings = dbDMRoom?.chattings.sorted {
                                $0.createdAt < $1.createdAt
                            }
                            let lastCreatedAt = dbChattings?.last?.createdAt ?? Date.firstDate
                            print("마지막 날짜는??", lastCreatedAt)
                            
                            // DB의 마지막 날짜 기준으로 DM 채팅 + Unread API 통신
                            let (dmChats, unreadCount) = try await fetchDMRoomDetails(
                                workspaceID: UserDefaultsManager.workspaceID,
                                roomID: dmRoom.id,
                                lastCreatedAt: lastCreatedAt
                            )
                            await send(.dmChatsResponse(dmRoom, dmChats))
                            await send(.unreadCountResponse(dmRoom, unreadCount))
                        } catch {
                            print("DM 채팅 조회 실패:", error)
                        }
                    }
                })
                
            case .dmChatsResponse(let dmRoom, let chats):
                if let lastChat = chats.last?.toPresentModel() {
                    state.dmLastChattings[dmRoom] = lastChat
                }
                return .none
                
            case .unreadCountResponse(let dmRoom, let unreadCount):
                state.dmUnreads[dmRoom] = unreadCount
                return .none
                
            case .inviteMemberResponse(let result):
                Notification.postToast(title: "초대에 성공했습니다")
                // 멤버 추가
                state.workspaceMembers.append(result)
                // 시트 내리기
                state.inviteMemberViewPresented = false
                return .none
                
                // MARK: - 네비게이션
            case .path(.element(id: _, action: .dmChatting(.profileButtonTap(let user)))):
                state.path.append(.profile(ProfileFeature.State(
                    profileType: .otherUser,
                    nickname: user.nickname,
                    email: user.email,
                    profileImage: user.profileImage ?? "bird"
                )))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension DMFeature {
    
    private func fetchInitialData() async throws -> ([WorkspaceResponse], MyProfileResponse) {
        // 내가 속한 워크스페이스 리스트 조회
        async let workspaces = workspaceClient.fetchMyWorkspaceList()
        // 내 프로필 조회
        async let profile = userClient.fetchMyProfile()
        return try await (workspaces, profile)
    }
    
    private func fetchWorkspaceDetails(
        workspaceID: String
    ) async throws -> ([Member], [DMsRoom]) {
        // 내가 속한 특정 워크스페이스 정보 조회 >> 워크 스페이스 멤버 리스트 얻기
        async let members = workspaceClient.fetchWorkspaceMembers(workspaceID)
        // DM 방 리스트 조회
        async let dmRooms = dmsClient.fetchDMSList(workspaceID)
        return try await (members.map { $0.toPresentModel() }, dmRooms.map { $0.toPresentModel() })
    }
    
    private func fetchDMRoomDetails(
        workspaceID: String,
        roomID: String,
        lastCreatedAt: String
    ) async throws -> ([DMsResponse], UnreadDMsResponse) {
        // DM 채팅 내역 리스트 조회 API
        async let fetchChattings = dmsClient.fetchDMChatHistory(
            workspaceID,
            roomID,
            lastCreatedAt
        )
        // unreadCount 조회 API
        async let fetchUnreadCount = dmsClient.fetchUnreadDMCount(
            workspaceID,
            roomID,
            lastCreatedAt
        )
        return try await (fetchChattings, fetchUnreadCount)
    }
}
