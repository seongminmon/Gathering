//
//  ChannelSettingView.swift
//  Gathering
//
//  Created by 여성은 on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

struct ChannelSettingView: View {
    
    @Perception.Bindable var store: StoreOf<ChannelSettingFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            mainView()
            // 채널 편집 화면
                .sheet(isPresented: $store.isEditChannelViewPresented) {
                    editChannelView()
                }
            // 관리자 변경 화면
                .sheet(isPresented: $store.isChangeAdminViewPresented) {
                    changeAdminView(
                        store.channelMembers.filter { $0.id != UserDefaultsManager.userID }
                    )
                }
            // 채널 삭제
                .customAlert(
                    isPresented: $store.isDeleteChannelAlertPresented,
                    title: "채널 삭제",
                    message: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.",
                    primaryButton: CustomAlert.AlertButton(title: "삭제") {
                        store.send(.deleteChannelAction)
                    },
                    secondaryButton: CustomAlert.AlertButton(title: "취소") {
                        store.send(.deleteChannelCancel)
                    }
                )
            // 채널 나가기 (관리자)
                .customAlert(
                    isPresented: $store.isAdminGetOutChannelAlertPresented,
                    title: "채널에서 나가기",
                    message: "회원님은 채널 관리자입니다. 채널 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다."
                )
            // 채널 나가기 (관리자 X)
                .customAlert(
                    isPresented: $store.isGetOutChannelAlertPresented,
                    title: "채널에서 나가기",
                    message: "나가기를 하면 채널 목록에서 삭제됩니다.",
                    primaryButton: CustomAlert.AlertButton(title: "나가기") {
                        store.send(.getOutChannelAction)
                    },
                    secondaryButton: CustomAlert.AlertButton(title: "취소") {
                        store.send(.getOutCancel)
                    }
                )
        }
    }
    
    private func mainView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("#\(store.currentChannel?.name ?? "채널명 없음")")
                    .font(Design.title2)
                    .padding(.vertical, 16)
                
                Text(store.currentChannel?.description ?? "채널 설명 없음")
                    .font(Design.body)
                
                CustomDisclosureGroup(
                    label: "멤버 (\(store.channelMembers.count))",
                    isExpanded: $store.isMemeberExpand) {
                        memberGridView()
                    }
                    .foregroundColor(Design.black)
                
                channelSettingButtonView()
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity)
        .customToolbar(
            title: "채널 설정",
            leftItem: .init(icon: .chevronLeft) {
                dismiss()
            }
        )
    }
    
    private func memberGridView() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(store.channelMembers, id: \.id) { member in
                VStack(alignment: .center) {
                    ProfileImageView(urlString: member.profileImage ?? "", size: 44)
                    
                    Text(member.nickname)
                        .font(Design.body)
                        .foregroundStyle(Design.darkGray)
                }
                .wrapToButton {
                    store.send(.memberCellTap(member))
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private func channelSettingButtonView() -> some View {
        VStack(spacing: 10) {
            if store.currentChannel?.owner_id == UserDefaultsManager.userID {
                Button {
                    store.send(.editChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "채널 편집",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.adminGetOutChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "채널에서 나가기",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.changeAdminButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "채널 관리자 변경",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.deleteChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "채널 삭제",
                        textColor: Design.red,
                        borderColor: Design.red
                    )
                }
            } else {
                Button {
                    store.send(.getOutChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "채널에서 나가기",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
            }
        }
    }
    
    private func editChannelView() -> some View {
        VStack {
            SheetHeaderView(title: "채널 편집")
                .background(Design.white)
            ScrollView {
                VStack(spacing: 24) {
                    TextFieldWithTitle(
                        title: "채널 이름",
                        placeholder: "채널 이름을 입력해주세요",
                        text: $store.title
                    )
                    TextFieldWithTitle(
                        title: "채널 설명",
                        placeholder: "채널 설명을 입력해주세요",
                        text: $store.description
                    )
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button {
                store.send(.editConfirmButtonTap)
            } label: {
                RoundedButton(
                    text: "완료",
                    foregroundColor: Design.white,
                    backgroundColor: store.buttonValid ? Design.green : Design.darkGray
                )
            }
            .disabled(!store.buttonValid)
            .padding([.horizontal, .bottom])
        }
        .background(Design.gray)
    }
    
    private func changeAdminView(_ members: [Member]) -> some View {
        VStack {
            SheetHeaderView(title: "관리자 변경")
                .background(Design.white)
            ScrollView {
                LazyVStack {
                    ForEach(members, id: \.id) { member in
                        HStack(spacing: 8) {
                            ProfileImageView(urlString: member.profileImage ?? "", size: 44)
                            VStack(alignment: .leading) {
                                Text(member.nickname)
                                    .font(Design.bodyBold)
                                Text(member.email)
                                    .font(Design.body)
                                    .foregroundStyle(Design.darkGray)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Design.gray)
        .onAppear {
            if members.isEmpty { store.send(.channelEmpty) }
        }
        // 채널 관리자 변경 불가
        .customAlert(
            isPresented: $store.isChannelEmptyAlertPresented,
            title: "채널 관리자 변경 불가",
            message: "채널 멤버가 없어 관리자 변경을 할 수 없습니다.",
            primaryButton: CustomAlert.AlertButton(title: "확인") {
                store.send(.channelEmptyConfirmAction)
            }
        )
    }
}
