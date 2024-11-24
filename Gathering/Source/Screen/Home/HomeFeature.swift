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
        case myProfileResponse(MyProfileResponse)
        //        case myWorkspaceListResponse([WorkspaceResponse])
        //        case startNewMessageTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
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
                state.destination = .DMChatting(DMChattingFeature.State(opponentID: "87b8dfe8-ed7c-4927-b2dd-9daac283758a"))
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
                        let (workspaceResult, profileResult) = try await fetchInitialData()
//                        await send(.myWorkspaceListResponse(workspaceResult))
                        await send(.myProfileResponse(profileResult))
                        
                        // 워크스페이스 ID 추출 (첫 번째 워크스페이스 ID 사용)
                        guard let workspaceID = workspaceResult.first?.workspace_id else {
                            Notification.postToast(title: "현재 워크 스페이스 없음")
                            return
                        }
                        
                        let (memberResult, dmRoomResult) = try await fetchWorkspaceDetails(
                            workspaceID: workspaceID
                        )
                        //                        await send(.dmRoomsResponse(dmRoomResult))
                        //                        await send(.loadingComplete)
                    } catch {
                        // 에러 처리
                    }
                }
            case .myProfileResponse:
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
