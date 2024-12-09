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
    
    // Unread할 때 DB 정보 불러오기 필요
    @Dependency(\.dbClient) var dbClient
    
    @Reducer
    enum Path {
        case profile(ProfileFeature)
        case channelChatting(ChannelChattingFeature)
        case channelSetting(ChannelSettingFeature)
        case dmChatting(DMChattingFeature)
    }
    
    @Reducer
    enum Destination {
        case channelAdd(CreateChannelFeature)
        case channelExplore(ExploreChannelFeature)
        case inviteMember(InviteMemberFeature)
    }
    
    // MARK: State -
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        
        var isChannelExpanded = true
        var isDMExpanded = true
        
        // 워크스페이스 + 프로필 데이터
        //        var myWorkspaceList: [WorkspaceResponse] = []
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
        var channelListResponse = [ChannelResponse]()
        var dmRoomListResponse = [DMsRoomResponse]()
        var channelList: [Channel] {
            return channelListResponse.map { $0.toPresentModel() }
        }
        var dmRoomList: [DMsRoom] {
            return dmRoomListResponse.map { $0.toPresentModel() }
        }
        
        var channelUnreads = [Channel: Int]()
        var dmUnreads = [DMsRoom: Int]()
    }

    // MARK: Action -
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        
        enum ConfirmationDialog {
            case createChannelButtonTap
            case exploreChannelButtonTap
        }
        
        // View에서 발생하는 사용자 액션들
        case addChannelButtonTap
        case inviteMemberButtonTap
        case floatingButtonTap
        case startNewMessageTap
        
        case channelTap(Channel)
        case dmTap(DMsRoom)
        
        case task
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        case channelListResponse([ChannelResponse])
        case dmRoomListResponse([DMsRoomResponse])
        //        case myWorkspaceListResponse([WorkspaceResponse])
        
        case unreadChannelCountResponse(Channel, Int?)
        case unreadDMCountResponse(DMsRoom, Int)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                // MARK: - 네비게이션 path
                
                // 채널 채팅 뷰 액션
            case .path(.element(id: _, action: .channelChatting(let action))):
                switch action {
                case .settingButtonTap(let channel):
                    state.path.append(.channelSetting(ChannelSettingFeature.State(
                        currentChannel: channel
                    )))
                case .profileButtonTap(let user):
                    state.path.append(.profile(ProfileFeature.State(
                        profileType: .otherUser,
                        nickname: user.nickname,
                        email: user.email,
                        profileImage: user.profileImage ?? "bird"
                    )))
//                case .onDisappear:
//                    print("채널 채팅 뷰 - onDisappear (부모 리듀서)")
                default:
                    break
                }
                return .none
            
                // 채널 세팅 뷰 액션
            case .path(.element(id: _, action: .channelSetting(let action))):
                switch action {
                case .memberCellTap(let user):
                    state.path.append(.profile(ProfileFeature.State(
                        profileType: .otherUser,
                        nickname: user.nickname,
                        email: user.email,
                        profileImage: user.profileImage ?? "bird"
                    )))
                case .exitChannelResponse:
                    state.path.removeAll()
                case .deleteChannelResponse:
                    state.path.removeAll()
                default:
                    break
                }
                return .none
                
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
                
                // MARK: destination -
            case .confirmationDialog(.presented(.createChannelButtonTap)):
                state.destination = .channelAdd(CreateChannelFeature.State())
                return .none
            case .confirmationDialog(.presented(.exploreChannelButtonTap)):
                state.destination = .channelExplore(ExploreChannelFeature.State())
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
            case .channelTap(let channel):
                print("홈뷰 채널 탭", channel.id)
                state.path.append(.channelChatting(ChannelChattingFeature.State(
                    channelID: channel.id
                )))
                return .none
            case .dmTap(let dmRoom):
                state.path.append(.dmChatting(DMChattingFeature.State(
                    dmsRoomResponse: dmRoom
                )))
                return .none
            case .startNewMessageTap:
                // RootFeature에서 탭바 전환
                return .none
            case .floatingButtonTap:
                // RootFeature에서 탭바 전환
                return .none
                
            case .destination(.presented(.channelExplore(.moveToChannelChattingView(let channel)))):
                state.destination = nil
                state.path.append(.channelChatting(ChannelChattingFeature.State(
                    channelID: channel.id
                )))
                return .none
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .destination:
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
                        
                        let (channelResult, dmRoomResult) = try await fetchWorkspaceDetails(
                            workspaceID: UserDefaultsManager.workspaceID
                        )
                        await send(.channelListResponse(channelResult))
                        await send(.dmRoomListResponse(dmRoomResult))
                        
                    } catch {
                        print(error)
                        print("error🔥")
                    }
                }
            case .myWorkspaceResponse(let workspace):
                state.currentWorkspace = workspace
                return .none
            case .myProfileResponse(let myProfile):
                state.myProfile = myProfile
                return .none
                
            case .channelListResponse(let result):
                state.channelListResponse = result
                return .merge(result.map { channel in
                    return .run { send in
                        do {
//                             ChannelDBResponse DB에 채널정보 있니?
                            let channelDB = try dbClient.fetchChannel(channel.channel_id)
                            // String 가져온 채널 DB에 마지막 채팅 날짜 저장되어있니?
                            let sortedChattings = channelDB?.chattings.sorted { $0.createdAt < $1.createdAt }
                            let readDate = sortedChattings?.last?.createdAt ?? ""
                            
                            if readDate == "" {
                                print("🔥 lastchannelReadDate 없음")
                            }
                            do {
                                let unreads = try await channelClient.fetchUnreadChannel(
                                    channel.channel_id,
                                    UserDefaultsManager.workspaceID,
                                    readDate
                                )
                                await send(.unreadChannelCountResponse(channel.toPresentModel(), unreads.count))
                                
                            } catch {
                                print("🔥 으아ㅏ아ㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏㅏ")
                            }
                            
                        } catch {
                            // DB에 채널 정보 없음
                            print("🔥 channelDB 없음")
                            await send(.unreadChannelCountResponse(channel.toPresentModel(), nil))
                        }
                        
                    }
                })
                
//                return .none
            case .dmRoomListResponse(let result):
//                state.dmRoomListResponse = result
//                return .merge(result.map { dmRoom in
//                    return .run { send in
//                        do {
//                            let dmRoomDB = try dbClient.fetchDMRoom(dmRoom.room_id)
//                            let sortedChattings = dmRoomDB?.chattings.sorted { $0.createdAt < $1.createdAt }
//                            let readDate = sortedChattings?.last?.createdAt ?? ""
//                            
//                            if readDate == "" {
//                                print(" 💬 lastDMReadDate 없음")
//                            }
//                            await send(.unreadDMCountResponse(dmRoom.toPresentModel(), readDate))
//                            
////                            let unreads = try await fetchDMRoomDetails(workspaceID: UserDefaultsManager.workspaceID,
////                                                                 roomID: dmRoom.room_id,
////                                                                 lastCreatedAt: readDate)
////                            let dmRoom = dmRoom.toPresentModel()
//                        } catch {
//                            print("🔥 dmRoomDB 없음")
//                            await send(.unreadDMCountResponse(dmRoom.toPresentModel(), ""))
//                        }
//                        
//                    }
//                })
                                return .none
                
            case .unreadChannelCountResponse(let channel, let unreadCount):
                state.channelUnreads[channel] = unreadCount
                print("✅ unreadChannelCountResponse?")
                return .none
                
            case .unreadDMCountResponse(let dmRoom, let unreadCount):
//                state.dmUnreads[dmRoom] = unreadCount
                return .none
            
            case .binding(\.currentWorkspace):
                return .none
            case .binding(\.myProfile):
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
    
    // MARK: methods -
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
    ) async throws -> (channels: [ChannelResponse], dmRooms: [DMsRoomResponse]) {
//        async let workspaces = workspaceClient.fetchMyWorkspaceList()
        // 채널 리스트 조회
        async let channels = channelClient.fetchMyChannelList(workspaceID)
        // DM 방 리스트 조회
        async let dmRooms = dmsClient.fetchDMSList(workspaceID)
        return try await (channels, dmRooms)
    }
    
    private func fetchChannelDetails(
        workspaceID: String,
        channelID: String,
        lastCreatedAt: String
    ) async throws -> UnreadChannelResponse {
        // unreadCount 조회 API
        async let unreadCountResponse = channelClient.fetchUnreadChannel(
            workspaceID,
            channelID,
            lastCreatedAt
        )
        return try await unreadCountResponse
    }
    
    private func fetchDMRoomDetails(
        workspaceID: String,
        roomID: String,
        lastCreatedAt: String
    ) async throws -> UnreadDMsResponse {
//        // DM 채팅 내역 리스트 조회 API
//        async let fetchChattings = dmsClient.fetchDMChatHistory(
//            workspaceID,
//            roomID,
//            lastCreatedAt
//        )
        // unreadCount 조회 API
        async let unreadCountResponse = dmsClient.fetchUnreadDMCount(
            workspaceID,
            roomID,
            lastCreatedAt
        )
        return try await unreadCountResponse
    }
}
