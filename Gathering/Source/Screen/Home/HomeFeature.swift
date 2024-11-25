//
//  HomeFeature.swift
//  Gathering
//
//  Created by dopamint on 11/13/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct HomeFeature {
    
    @Dependency(\.workspaceClient) var workspaceClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.channelClient) var channelClient
    @Dependency(\.dmsClient) var dmsClient
    @Dependency(\.realmClient) var realmClient
    
    @Reducer
    enum Destination {
        case channelAdd(CreateChannelFeature)
        case channelExplore(ChannelExploreFeature)
        case inviteMember(InviteMemberFeature)
        case channelChatting(ChannelChattingFeature)
        case DMChatting(DMChattingFeature)
    }
    
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        
        var isChannelExpanded = true
        var isDMExpanded = true
        
        var channels: [Channel] = Dummy.channels
        var users: [DMUser] = Dummy.users
        
        // 워크스페이스 + 프로필 데이터
        //        var myWorkspaceList: [WorkspaceResponse] = []
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
        var workspaceMembers: [Member] = []
        var dmRoomList: [DMsRoom] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        
        enum ConfirmationDialog {
            case createChannelButtonTap
            case exploreChannelButtonTap
        }
        //        // View에서 발생하는 사용자 액션들
        case addChannelButtonTap
        case inviteMemberButtonTap
        case floatingButtonTap
        
        case channelTap(Channel)
        case dmTap(DMUser)
        
        case task
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        //        case myWorkspaceListResponse([WorkspaceResponse])
        //        case startNewMessageTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                // MARK: destination -
            case .confirmationDialog(.presented(.createChannelButtonTap)):
                state.destination = .channelAdd(CreateChannelFeature.State())
                return .none
            case .confirmationDialog(.presented(.exploreChannelButtonTap)):
                state.destination = .channelExplore(ChannelExploreFeature.State())
                return .none
            case .addChannelButtonTap:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("")
                } actions: {
                    ButtonState(action: .createChannelButtonTap) {
                        TextState("채널 생성")
                    }
                    ButtonState(action: .exploreChannelButtonTap) {
                        TextState("채널 탐색")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                }
                return .none
            case .inviteMemberButtonTap:
                state.destination = .inviteMember(InviteMemberFeature.State())
                return .none
            case .channelTap:
                state.destination = .channelChatting(ChannelChattingFeature.State(
                    channelID: "f755a2b0-547a-4215-8f72-af1be294ce09", workspaceID: "4e31f58f-aedd-4b3a-a4cb-b7597fafe8d2"
                ))
                return .none
            case .dmTap:
                state.destination = .DMChatting(DMChattingFeature.State())
                return .none
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .destination:
                return .none
                
            case .floatingButtonTap:
                return .none
            case .confirmationDialog(.dismiss):
                return .none
                // MARK: networking -
            case .task:
                //                state.isLoading = true
                return .run { send in
                    do {
                        // 워크스페이스 리스트, 유저 정보 가져오기
                        let (workspaceResult, profileResult) = try await fetchInitialData()
                        // ✅ 불러오기 성공
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
                        
                    } catch {
                        // 에러 처리
                    }
                }
            case .myWorkspaceResponse(let workspace):
                state.currentWorkspace = workspace
                return .none
            case .myProfileResponse(let result):
                state.myProfile = result
                return .none
            case .binding(\.currentWorkspace):
                return .none
            case .binding(\.myProfile):
                return .none
                
            case .binding:
                return .none

            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
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
