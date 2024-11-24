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
    
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        // 이전 화면에서 전달 (멤버 정보들까지 포함) (테스트 데이터)
        var currentChannel: ChannelResponse? = ChannelResponse(
            channel_id: "c4cf80b2-ab7e-4d72-9d92-263c6d960cb1",
            name: "test",
            description: "test  채널입니다.",
            coverImage: "/static/channelCoverImages/1731223059386.jpg",
//            owner_id: "973d62ec-1776-446f-90ea-f35d189bb7b3",
            owner_id: "abcabc",
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
        
        var isMemeberExpand = true
        
        // 채널 편집 화면
        var isEditChannelViewPresented = false
        // 관리자 채널 나가기
        var isAdminGetOutChannelAlertPresented = false
        // 채널 관리자 변경 화면
        var isChangeAdminViewPresented = false
        // 채널 삭제 화면
        var idDeleteChannelAlertPresented = false
        
        // 채널 나가기
        var isGetOutChannelAlertPresented = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        // 관리자 버튼
        case editChannelButtonTap
        case adminGetOutChannelButtonTap
        case changeAdminButtonTap
        case deleteChannelButtonTap
        
        // 관리자 X 버튼
        case getOutChannelButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .editChannelButtonTap:
                state.isEditChannelViewPresented = true
                return .none
            case .adminGetOutChannelButtonTap:
                state.isAdminGetOutChannelAlertPresented = true
                return .none
            case .changeAdminButtonTap:
                state.isChangeAdminViewPresented = true
                return .none
            case .deleteChannelButtonTap:
                state.idDeleteChannelAlertPresented = true
                return .none
            case .getOutChannelButtonTap:
                state.isGetOutChannelAlertPresented = true
                return .none
            }
        }
    }
    
}
