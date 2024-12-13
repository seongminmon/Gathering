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
        var selectedChannel: Channel?
        var showAlert = false
    }
    
    enum Action: BindableAction {
        case path(StackAction<Path.State, Path.Action>)
        case binding(BindingAction<State>)
        
        case onAppear
        case channelCellTap(Channel)
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
        case channelResponse([Channel], [Channel])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .path:
                return .none
                
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
                    } catch {
                        print(error)
                        print("error🔥")
                    }
                }
                
            case .channelCellTap(let channel):
                print("채널 셀 탭")
                state.selectedChannel = channel
                // MARK: - 참여 중이면 채팅방으로, 참여 중이 아니면 얼럿
                if state.myChannels.contains(channel) {
                    // TODO: - 채팅방 이동
                    print("채팅방 이동")
                } else {
                    state.showAlert = true
                }
                return .none
                
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
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ExploreFeature {
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
    
    private func fetchChannelData() async throws -> ([Channel], [Channel]) {
        let workspaceID = UserDefaultsManager.workspaceID
        async let allChannels = channelClient.fetchChannelList(workspaceID)
        async let myChannels = channelClient.fetchMyChannelList(workspaceID)
        return try await (
            allChannels.map { $0.toPresentModel() },
            myChannels.map { $0.toPresentModel() }
        )
    }
}
