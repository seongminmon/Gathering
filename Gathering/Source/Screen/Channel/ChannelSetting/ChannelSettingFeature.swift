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
    @Dependency(\.dbClient) var dbClient
    
    @ObservableState
    struct State {
        // 이전 화면에서 전달 (멤버 정보들까지 포함)
        var currentChannel: ChannelResponse?
        
        var channelMembers: [Member] {
            return currentChannel?.channelMembers?.map { $0.toPresentModel() } ?? []
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
        var selectedImage: [UIImage]? = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        
        case memberCellTap(Member)
        
        // 채널 편집
        case editChannelButtonTap
        case editConfirmButtonTap
        case deleteImageButtonTapped
        
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
        case changeAdminResponse(ChannelResponse)
        case deleteChannelResponse
        case updateChannelResponse(ChannelResponse)
        case fetchChannelImage(UIImage)
        case fetchChannelInfo
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
                // MARK: - Binding
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
                        let data =  state.selectedImage?.last?.jpegData(compressionQuality: 0.5)
                        
                        let result = try await channelClient.editChannel(
                            state.currentChannel?.channel_id ?? "",
                            UserDefaultsManager.workspaceID,
                            ChannelRequest(
                                name: state.title,
                                description: state.description,
                                image: data
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
                state.isChangeAdminAlertPresented = false
                return .run { [state = state] send in
                    do {
                        let result = try await channelClient.changeOwner(
                            state.currentChannel?.channel_id ?? "",
                            UserDefaultsManager.workspaceID,
                            OwnerRequest(ownerID: member?.id ?? "")
                        )
                        await send(.changeAdminResponse(result))
                    } catch {
                        Notification.postToast(title: "채널 관리자 변경 실패")
                    }
                }
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
                return .run { [state = state] send in
                    do {
                        try await channelClient.deleteChannel(
                            state.currentChannel?.channel_id ?? "",
                            UserDefaultsManager.workspaceID
                        )
                        await send(.deleteChannelResponse)
                    } catch {
                        if let error = error as? ErrorResponse {
                            switch error.errorCode {
                            case "E11":
                                Notification.postToast(title: "기본 채널은 삭제가 불가능합니다")
                            default:
                                Notification.postToast(title: "채널 삭제 실패")
                            }
                        }
                    }
                }
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
            case .editChannelResponse(let result):
                state.isEditChannelViewPresented = false
                Notification.postToast(title: "채널이 편집되었습니다")
                // 채널 정보 갱신
                return .run { send in
                    do {
                        let result = try await channelClient.fetchChannel(
                            result.channel_id,
                            UserDefaultsManager.workspaceID
                        )
                        await send(.updateChannelResponse(result))
                    } catch {}
                }
            case .changeAdminResponse(let result):
                state.isChangeAdminViewPresented = false
                Notification.postToast(title: "채널 관리자가 변경되었습니다")
                // 채널 정보 갱신
                return .run { send in
                    do {
                        let result = try await channelClient.fetchChannel(
                            result.channel_id,
                            UserDefaultsManager.workspaceID
                        )
                        await send(.updateChannelResponse(result))
                    } catch {}
                }
            case .deleteChannelResponse:
                // 홈 뷰에서 path로 관리
                state.isDeleteChannelAlertPresented = false
                removeDBChannel(state.currentChannel?.channel_id)
                return .none
            case .exitChannelResponse:
                // 홈 뷰에서 path로 관리
                removeDBChannel(state.currentChannel?.channel_id)
                return .none
            case .updateChannelResponse(let result):
                state.currentChannel = result
                return .none
            case .deleteImageButtonTapped:
                state.selectedImage = []
                return .none
                
            case .task:
                return .run { [state = state] send in
                    do {
                        guard let urlString = state.currentChannel?.coverImage else { return }
                        let result = try await NetworkManager.shared.requestImage(
                            ImageRouter.fetchImage(path: urlString)
                        )
                        await send(.fetchChannelInfo)
                        return await send(.fetchChannelImage(result))
                    } catch {}
                    
                }
                
            case .fetchChannelImage(let image):
                state.selectedImage = [image]
                return .none
            case .fetchChannelInfo:
                state.title = state.currentChannel?.name ?? ""
                state.description = state.currentChannel?.description ?? ""
                return .none
            }
            
        }
    }
    
    private func removeDBChannel(_ channelID: String?) {
        guard let channelID else {
            print("DB 삭제할 채널 ID 없음")
            return
        }
        do {
            if let dbChannel = try dbClient.fetchChannel(channelID) {
                // 파일 매니저 삭제
                for item in dbChannel.chattings {
                    for fileName in item.files {
                        ImageFileManager.shared.deleteImageFile(filename: fileName)
                    }
                }
                try dbClient.delete(dbChannel)
                print("DB 채널 삭제 완료!")
            }
        } catch {}
    }
}
