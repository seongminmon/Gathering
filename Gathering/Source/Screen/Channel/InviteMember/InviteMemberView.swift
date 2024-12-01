//
//  InviteMemberView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

import ComposableArchitecture

struct InviteMemberView: View {
    @Perception.Bindable var store: StoreOf<InviteMemberFeature>
    
    @State private var userEmail: String = ""
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                SheetHeaderView(title: "팀원 초대")
                    .background(Design.white)
                ScrollView {
                    TextFieldWithTitle(
                        title: "이메일",
                        placeholder: "초대하려는 팀원의 이메일을 입력하세요.",
                        text: $store.email
                    )
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                inviteButton()
                    .padding([.horizontal, .bottom])
            }
            .background(Design.gray)
        }
    }
    
    private func inviteButton() -> some View {
        Button {
            store.send(.inviteMemberButtonTap)
        } label: {
            RoundedButton(
                text: "초대 보내기",
                foregroundColor: Design.white,
                backgroundColor: store.inviteButtonValid ? Design.green : Design.darkGray
            )
        }
        .disabled(!store.inviteButtonValid)
    }
}
