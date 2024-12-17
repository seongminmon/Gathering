//
//  ExploreFeature.swift
//  Gathering
//
//  Created by 김성민 on 12/12/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ExploreFeature {
    
    @Dependency(\.workspaceClient) var workspaceClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.channelClient) var channelClient
    
    @Reducer
    enum Path {
        case channelChatting(ChannelChattingFeature)
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
        
        var allChannels: [Channel] = []
        var myChannels: [Channel] = []
        var channelOwners = [String: Member]()
        
        var selectedChannel: Channel?
        var showAlert = false
        
        // 검색 관련 상태 추가
        var searchText = "" // 검색어를 저장할 상태
        var filteredChannels: [Channel] { // 검색어에 따라 필터링된 채널 목록
            if searchText.isEmpty {
                return allChannels
            } else {
                return allChannels.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText) ||
                    ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    enum Action: BindableAction {
        case path(StackAction<Path.State, Path.Action>)
        case binding(BindingAction<State>)
        
        case onAppear
        case channelCellTap(Channel)
        case confirmJoinChannel(Channel?)
        case cancelJoinChannel
        case moveToChannelChattingView(Channel)
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        case channelResponse([Channel], [Channel])
        case channelDetailResponse(Channel, [Member], Member)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
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
                
                // MARK: - 유저 액션
            case .onAppear:
                return .run { send in
                    do {
                        // 워크스페이스 리스트, 유저 정보 가져오기
                        let (workspaceResult, profileResult) = try await fetchInitialData()
                        // ✅ 불러오기 성공
                        await send(.myProfileResponse(profileResult))
                        
                        if let filtered = workspaceResult.filter({
                            $0.workspace_id == UserDefaultsManager.workspaceID
                        }).first {
                            // UserDefaults에 있는 워크스페이스 선택
                            await send(.myWorkspaceResponse(filtered))
                        } else {
                            // UserDefaults에 없으면 첫번째 워크스페이스 선택
                            guard let workspaceID = workspaceResult.first?.workspace_id else {
                                return
                            }
                            UserDefaultsManager.saveWorkspaceID(workspaceID)
                            await send(.myWorkspaceResponse(workspaceResult.first))
                        }
                        
                        let (allChannels, myChannels) = try await fetchChannelData()
                        await send(.channelResponse(allChannels, myChannels))
                        
                        // 병렬 채널 상세 정보 페치
                        await withTaskGroup(of: Void.self) { group in
                            for channel in allChannels {
                                group.addTask {
                                    do {
                                        let (channelMembers, owner) = try await fetchChannelDetail(channel)
                                        await send(.channelDetailResponse(channel, channelMembers, owner))
                                    } catch {
                                        print("채널 디테일 통신 실패")
                                    }
                                }
                            }
                        }
                        
//                        for channel in allChannels {
//                            let (channelMembers, owner) = try await fetchChannelDetail(channel)
//                            await send(.channelDetailResponse(channel, channelMembers, owner))
//                        }
                        
                    } catch {
                        print(error)
                        print("error🔥")
                    }
                }
                
            case .channelCellTap(let channel):
                // 참여 중이면 채팅방 아니면 얼럿
                if state.myChannels.contains(where: { $0.id == channel.id }) {
                    return .send(.moveToChannelChattingView(channel))
                } else {
                    state.selectedChannel = channel
                    state.showAlert = true
                    return .none
                }
                
            case let .confirmJoinChannel(channel):
                guard let channel else { return .none }
                
                state.showAlert = false
                return .run { send in
                    do {
                        _ = try await channelClient.fetchChattingList(
                            channel.id,
                            UserDefaultsManager.workspaceID,
                            ""
                        )
                        await send(.moveToChannelChattingView(channel))
                    } catch {
                        print("채널 참여 실패")
                    }
                }
                
            case .cancelJoinChannel:
                state.showAlert = false
                state.selectedChannel = nil
                return .none
                
            case let .moveToChannelChattingView(channel):
                // 채널 채팅방 이동
                state.path.append(.channelChatting(ChannelChattingFeature.State(
                    channelID: channel.id
                )))
                return .none
                
                // MARK: - 네트워킹
            case .myWorkspaceResponse(let workspace):
                state.currentWorkspace = workspace
                return .none
                
            case .myProfileResponse(let myProfile):
                state.myProfile = myProfile
                return .none
                
            case let .channelResponse(allChannels, myChannels):
                state.allChannels = allChannels
                state.myChannels = myChannels
                return .none
                
            case let .channelDetailResponse(channel, members, owner):
                if let index = state.allChannels.firstIndex(of: channel) {
                    state.allChannels[index].channelMembers = members
                }
                state.channelOwners[channel.id] = owner
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ExploreFeature {
    
    /// 내가 속한 워크스페이스 리스트 / 내 프로필 조회
    private func fetchInitialData() async throws -> (
        workspaceList: [WorkspaceResponse],
        profile: MyProfileResponse
    ) {
        async let workspaces = workspaceClient.fetchMyWorkspaceList()
        async let profile = userClient.fetchMyProfile()
        return try await (workspaces, profile)
    }
    
    /// 전체 채널 리스트 / 내가 속한 채널 리스트 조회
    private func fetchChannelData() async throws -> ([Channel], [Channel]) {
        let workspaceID = UserDefaultsManager.workspaceID
        async let allChannels = channelClient.fetchChannelList(workspaceID)
        async let myChannels = channelClient.fetchMyChannelList(workspaceID)
        return try await (
            allChannels.map { $0.toPresentModel() },
            myChannels.map { $0.toPresentModel() }
        )
    }
    
    /// 채널 상세 정보 / 채널 주인 프로필 조회
    private func fetchChannelDetail(_ channel: Channel) async throws -> ([Member], Member) {
        let workspaceID = UserDefaultsManager.workspaceID
        async let channelDetail = channelClient.fetchChannel(channel.id, workspaceID)
        async let ownerDetail = userClient.fetchUserProfile(channel.owner_id)
        return try await (
            channelDetail.channelMembers?.map { $0.toPresentModel() } ?? [],
            ownerDetail.toPresentModel()
        )
    }
}
