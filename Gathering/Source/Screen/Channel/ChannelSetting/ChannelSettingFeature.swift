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
    
    @Dependency(\.channelClient) var channelClient

    @ObservableState
    struct State {
        // TODO: - 채널 편집이나 채널 관리자 변경 후에 갱신된 정보 필요
        
        // 이전 화면에서 전달 (멤버 정보들까지 포함)
        var currentChannel: ChannelResponse?
        
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
        var isChannelEmptyAlertPresented = false
        var isChangeAdminAlertPresented = false
        var changeAdminTarget: Member?
        
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
        
        // 채널 편집
        case editChannelButtonTap
        case editConfirmButtonTap
        
        // 채널 나가기 (관리자)
        case adminGetOutChannelButtonTap
        
        // 채널 관리자 변경
        case changeAdminButtonTap
        case channelEmpty
        case channelEmptyConfirmAction
        case changeAdminCellTap(Member)
        case changeAdminAction(Member?)
        case changeAdminCancel
        
        // 채널 삭제 버튼
        case deleteChannelButtonTap
        case deleteChannelAction
        case deleteChannelCancel
        
        // 나가기 버튼 (관리자 X)
        case getOutChannelButtonTap
        case getOutChannelAction
        case getOutCancel
        
        // 내부 Action
        case exitChannelResponse([ChannelResponse])
        case editChannelResponse(ChannelResponse)
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
                return .none
                
            case .editChannelButtonTap:
                state.isEditChannelViewPresented = true
                return .none
                
            case .editConfirmButtonTap:
                return .run { [state = state] send in
                    do {
                        let result = try await channelClient.editChannel(
                            state.currentChannel?.channel_id ?? "",
                            UserDefaultsManager.workspaceID,
                            ChannelRequest(
                                name: state.title,
                                description: state.description,
                                image: nil
                            )
                        )
                        await send(.editChannelResponse(result))
                    } catch {
                        if let error = error as? ErrorResponse {
                            switch error.errorCode {
                            case "E12":
                                Notification.postToast(title: "이미 있는 채널 이름입니다.\n다른 이름을 입력해주세요.")
                            default:
                                Notification.postToast(title: "채널 편집 실패")
                            }
                        }
                    }
                }
                
            case .adminGetOutChannelButtonTap:
                state.isAdminGetOutChannelAlertPresented = true
                return .none
                
            case .changeAdminButtonTap:
                state.isChangeAdminViewPresented = true
                return .none
            case .changeAdminCellTap(let member):
                state.isChangeAdminAlertPresented = true
                state.changeAdminTarget = member
                return .none
            case .changeAdminAction(let member):
                print("채널 관리자 변경", member ?? "멤버 없음")
                // TODO: - 채널 관리자 변경 API
                state.isChangeAdminAlertPresented = false
                return .none
            case .changeAdminCancel:
                state.isChangeAdminAlertPresented = false
                return .none
            case .channelEmpty:
                state.isChannelEmptyAlertPresented = true
                return .none
            case .channelEmptyConfirmAction:
                state.isChannelEmptyAlertPresented = false
                state.isChangeAdminViewPresented = false
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
                state.isGetOutChannelAlertPresented = false
                return .run { [state = state] send in
                    do {
                        let result = try await channelClient.exitChannel(
                            state.currentChannel?.channel_id ?? "",
                            UserDefaultsManager.workspaceID
                        )
                        await send(.exitChannelResponse(result))
                    } catch {
                        if let error = error as? ErrorResponse {
                            switch error.errorCode {
                            case "E11":
                                Notification.postToast(title: "기본 채널은 퇴장이 불가능합니다")
                            default:
                                Notification.postToast(title: "채널 나가기 실패")
                            }
                        }
                    }
                }
            case .getOutCancel:
                state.isGetOutChannelAlertPresented = false
                return .none
                
                // MARK: - 네트워킹
            case .editChannelResponse:
                state.isEditChannelViewPresented = false
                Notification.postToast(title: "채널이 편집되었습니다")
                return .none
            case .exitChannelResponse:
                // 홈 뷰에서 path로 관리
                return .none
            }
        }
    }
}
