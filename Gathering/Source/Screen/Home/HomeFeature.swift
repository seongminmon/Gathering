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
    @Reducer
    enum Destination {
        case channelAdd(CreateChannelFeature)
        case channelExplore(ChannelExploreFeature)
        case inviteMember(InviteMemberFeature)
        case channelChatting(ChannelChattingFeature)
        case DMChatting(DMChattingFeature)
    }
    
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        
        var isChannelExpanded = true
        var isDMExpanded = true
        
        var channels: [Channel] = Dummy.channels
        var users: [DMUser] = Dummy.users
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        
        enum ConfirmationDialog {
            case createChannelButtonTap
            case exploreChannelButtonTap
        }
//        // View에서 발생하는 사용자 액션들
        case addChannelButtonTap
        case inviteMemberButtonTap
        case floatingButtonTap
        
        case channelTap(Channel)
        case dmTap(DMUser)
//        case startNewMessageTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .confirmationDialog(.presented(.createChannelButtonTap)):
                state.destination = .channelAdd(CreateChannelFeature.State())
                return .none
            case .confirmationDialog(.presented(.exploreChannelButtonTap)):
                state.destination = .channelExplore(ChannelExploreFeature.State())
                return .none
            case .addChannelButtonTap:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("")
                } actions: {
                    ButtonState(action: .createChannelButtonTap) {
                        TextState("채널 생성")
                    }
                    ButtonState(action: .exploreChannelButtonTap) {
                        TextState("채널 탐색")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                }
                return .none
            case .inviteMemberButtonTap:
                state.destination = .inviteMember(InviteMemberFeature.State())
                return .none
            case .channelTap:
                state.destination = .channelChatting(ChannelChattingFeature.State(
                    channelID: "f755a2b0-547a-4215-8f72-af1be294ce09", workspaceID: "4e31f58f-aedd-4b3a-a4cb-b7597fafe8d2"
                ))
                return .none
            case .dmTap:
                state.destination = .DMChatting(DMChattingFeature.State())
                return .none
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .destination:
                return .none
            case .floatingButtonTap:
                return .none
            case .confirmationDialog(.dismiss):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
