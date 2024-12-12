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
    
    @Reducer
    enum Path {
        case channelChatting(ChannelChattingFeature)
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        // 더미 데이터
        var channelList = [
            ChannelResponse(
                channel_id: "482b48d9-816b-40cb-9f92-6dbd38573474",
                name: "일본",
                description: "다녀오겠습니다",
                coverImage: "/static/channelCoverImages/1732725591572.jpg",
                owner_id: "58fa7648-747b-461f-951a-23171abf3619",
                createdAt: "2024-11-27T16:39:51.581Z",
                channelMembers: [
                    MemberResponse(
                        user_id: "973d62ec-1776-446f-90ea-f35d189bb7b3",
                        email: "ksm1@ksm.com",
                        nickname: "ksm1",
                        profileImage: "/static/profiles/1732090604584.jpg"
                    )
                ]
            ),
            ChannelResponse(
                channel_id: "f73a009e-59f5-4e9b-9543-b7a9107a9e07",
                name: "생겨랏",
                description: "ㅁㅁ",
                coverImage: "/static/channelCoverImages/1732724681664.jpg",
                owner_id: "58fa7648-747b-461f-951a-23171abf3619",
                createdAt: "2024-11-27T16:24:41.667Z",
                channelMembers: []
            )
        ]
        
        var currentWorkspace: WorkspaceResponse?
        var myProfile: MyProfileResponse?
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case onAppear
        
        case myWorkspaceResponse(WorkspaceResponse?)
        case myProfileResponse(MyProfileResponse)
    }
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
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
                        
//                        let (channelResult, dmRoomResult) = try await fetchWorkspaceDetails(
//                            workspaceID: UserDefaultsManager.workspaceID
//                        )
//                        await send(.channelListResponse(channelResult))
//                        await send(.dmRoomListResponse(dmRoomResult))
                        
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
}
