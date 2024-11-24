//
//  ChannelSettingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelSettingFeature {
    
    @Reducer
    enum Path {

    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        // 이전 화면에서 전달 (멤버 정보들까지 포함) (테스트 데이터)
        var currentChannel: ChannelResponse? = ChannelResponse(
            channel_id: "c4cf80b2-ab7e-4d72-9d92-263c6d960cb1",
            name: "test",
            description: "test  채널입니다.",
            coverImage: "/static/channelCoverImages/1731223059386.jpg",
            owner_id: "973d62ec-1776-446f-90ea-f35d189bb7b3",
            createdAt: "2024-11-10T07:17:39.449Z",
            channelMembers: [
                MemberResponse(
                    user_id: "973d62ec-1776-446f-90ea-f35d189bb7b3",
                    email: "ksm1@ksm.com",
                    nickname: "ksm1",
                    profileImage: "/static/profiles/1732090604584.jpg"
                )
            ]
        )
    }
    
    enum Action {
        case path(StackActionOf<Path>)
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
