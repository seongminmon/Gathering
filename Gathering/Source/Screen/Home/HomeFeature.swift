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
        //        var isDMExpanded = true
        
        // 워크스페이스 + 프로필 데이터
        //        var myWorkspaceList: [WorkspaceResponse] = []
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
        var channelListResponse = [ChannelResponse]()
        var channelList: [Channel] {
            return channelListResponse.map { $0.toPresentModel() }
        }
        
        var channelUnreads = [Channel: Int]()
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
        
        case task
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        case channelListResponse([ChannelResponse])
        
        case unreadChannelCountResponse(Channel, Int?)
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
                
            case .path:
                return .none
                
                // MARK: destination -
            case .confirmationDialog(.presented(.createChannelButtonTap)):
                state.destination = .channelAdd(CreateChannelFeature.State())
                return .none
            case .confirmationDialog(.presented(.exploreChannelButtonTap)):
//                state.destination = .channelExplore(ExploreChannelFeature.State())
                return .none
            case .addChannelButtonTap:
                state.destination = .channelAdd(CreateChannelFeature.State())
//                state.confirmationDialog = ConfirmationDialogState {
//                    TextState("")
//                } actions: {
//                    ButtonState(action: .createChannelButtonTap) {
//                        TextState("채널 생성")
//                    }
//                    ButtonState(action: .exploreChannelButtonTap) {
//                        TextState("채널 탐색")
//                    }
//                    ButtonState(role: .cancel) {
//                        TextState("취소")
//                    }
//                }
                return .none
               
            case .inviteMemberButtonTap:
                state.destination = .inviteMember(InviteMemberFeature.State())
                return .none
            case .channelTap(let channel):
                state.path.append(.channelChatting(ChannelChattingFeature.State(
                    channelID: channel.id
                )))
                print("홈뷰 채널 탭", channel.id)
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
            case .destination(.presented(.channelAdd(.channelCreated))):
                return .send(.task)
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
                            UserDefaultsManager.saveWorkspaceID(workspaceID)
                            await send(.myWorkspaceResponse(workspaceResult.first))
                        }
                        
                        let channelResult = try await fetchWorkspaceDetails(
                            workspaceID: UserDefaultsManager.workspaceID
                        )
                        await send(.channelListResponse(channelResult))
                        
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
                            // ChannelDBResponse DB에 채널정보 있니?
                            let channelDB = try dbClient.fetchChannel(channel.channel_id)
                            // String 가져온 채널 DB에 마지막 채팅 날짜 저장되어있니?
                            let sortedChattings = channelDB?.chattings.sorted {
                                $0.createdAt < $1.createdAt
                            }
                            let readDate = sortedChattings?.last?.createdAt ??
                            Date.firstDate
                            do {
                                let unreads = try await channelClient.fetchUnreadChannel(
                                    channel.channel_id,
                                    UserDefaultsManager.workspaceID,
                                    readDate
                                )
                                await send(.unreadChannelCountResponse(
                                    channel.toPresentModel(),
                                    unreads.count)
                                )
                                
                            } catch {
                                print("🔥 으아ㅏ아ㅏㅏㅏㅏㅏ")
                            }
                            
                        } catch {
                            // DB에 채널 정보 없음
                            print("🔥 channelDB 없음")
                            await send(.unreadChannelCountResponse(channel.toPresentModel(), nil))
                        }
                        
                    }
                })
                
            case .unreadChannelCountResponse(let channel, let unreadCount):
                state.channelUnreads[channel] = unreadCount
                print("✅ unreadChannelCountResponse?")
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
    ) async throws -> [ChannelResponse] {
        // 채널 리스트 조회
        async let channels = channelClient.fetchMyChannelList(workspaceID)
        return try await channels
    }
}
