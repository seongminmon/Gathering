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
    
    @Reducer
    enum Path {
        case channelChatting(ChannelChattingFeature)
        case channelSetting(ChannelSettingFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
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
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
