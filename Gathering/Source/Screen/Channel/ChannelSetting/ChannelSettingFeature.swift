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
        // 이전 화면에서 전달 (멤버 정보들까지 포함)
        var currentChannel: ChannelResponse?
//        var channelMembers: [Member] = []
        
        var channelMembers: [Member] {
            return currentChannel?.channelMembers?.map { $0.toMember } ?? []
        }
        
        var isMemeberExpand = true
        
        // 채널 편집 화면
        var isEditChannelViewPresented = false
        // 관리자 채널 나가기
        var isAdminGetOutChannelAlertPresented = false
        // 채널 관리자 변경 화면
        var isChangeAdminViewPresented = false
        // 채널 삭제 화면
        var isDeleteChannelAlertPresented = false
        
        // 채널 나가기
        var isGetOutChannelAlertPresented = false
        
        // 채널 편집 화면
        var title = ""
        var description = ""
        var buttonValid = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case memberCellTap(Member)
        
        // 관리자 버튼
        case editChannelButtonTap
        case adminGetOutChannelButtonTap
        case changeAdminButtonTap
        
        // 채널 삭제
        case deleteChannelButtonTap
        case deleteChannelAction
        case deleteChannelCancel
        
        // 관리자 X 버튼
        case getOutChannelButtonTap
        case getOutChannelAction
        case getOutCancel
        
        // 채널 편집 화면
        case editConfirmButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.title):
                state.buttonValid = !state.title.isEmpty
                return .none
            case .binding(\.isEditChannelViewPresented):
                state.title = ""
                state.description = ""
                state.buttonValid = !state.title.isEmpty
                return .none
            case .binding:
                return .none
                
            case .memberCellTap:
                // 홈 뷰에서 path를 통해 화면 이동
                print("멤버셀 탭")
                return .none
                
            case .editChannelButtonTap:
                state.isEditChannelViewPresented = true
                return .none
                
            case .editConfirmButtonTap:
                print("채널 편집 완료 버튼 탭")
                state.isEditChannelViewPresented = false
                // TODO: - 채널 편집 API
                return .none
                
            case .adminGetOutChannelButtonTap:
                state.isAdminGetOutChannelAlertPresented = true
                return .none
                
            case .changeAdminButtonTap:
                state.isChangeAdminViewPresented = true
                return .none
                
            case .deleteChannelButtonTap:
                state.isDeleteChannelAlertPresented = true
                return .none
            case .deleteChannelAction:
                // TODO: - 채널 삭제 API
                // TODO: - 삭제 성공 시 홈 화면으로 전환
                print("채널 삭제 액션")
                state.isDeleteChannelAlertPresented = false
                return .none
            case .deleteChannelCancel:
                state.isDeleteChannelAlertPresented = false
                return .none
                
            case .getOutChannelButtonTap:
                state.isGetOutChannelAlertPresented = true
                return .none
            case .getOutChannelAction:
                print("채널 나가기 액션")
                state.isGetOutChannelAlertPresented = false
                // TODO: - 채널 나가기 API
                // TODO: - 나가기 성공 시 홈 화면으로 전환
                return .none
            case .getOutCancel:
                state.isGetOutChannelAlertPresented = false
                return .none
            }
        }
    }
}
