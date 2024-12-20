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
            // 모임 편집 화면
                .sheet(isPresented: $store.isEditChannelViewPresented) {
                    editChannelView()
                }
            // 관리자 변경 화면
                .sheet(isPresented: $store.isChangeAdminViewPresented) {
                    changeAdminView(
                        store.channelMembers.filter { $0.id != UserDefaultsManager.userID }
                    )
                }
            // 모임 삭제
                .customAlert(
                    isPresented: $store.isDeleteChannelAlertPresented,
                    title: "모임 삭제",
                    message: "정말 이 모임을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 모임 내의 모든 정보가 삭제되며 복구할 수 없습니다.",
                    primaryButton: CustomAlert.AlertButton(title: "삭제") {
                        store.send(.deleteChannelAction)
                    },
                    secondaryButton: CustomAlert.AlertButton(title: "취소") {
                        store.send(.deleteChannelCancel)
                    }
                )
            // 모임 나가기 (관리자)
                .customAlert(
                    isPresented: $store.isAdminGetOutChannelAlertPresented,
                    title: "모임에서 나가기",
                    message: "회원님은 모임 관리자입니다. 모임 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다."
                )
            // 모임 나가기 (관리자 X)
                .customAlert(
                    isPresented: $store.isGetOutChannelAlertPresented,
                    title: "모임에서 나가기",
                    message: "나가기를 하면 모임 목록에서 삭제됩니다.",
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
                Text("#\(store.currentChannel?.name ?? "모임명 없음")")
                    .font(Design.title2)
                    .padding(.vertical, 16)
                
                Text(store.currentChannel?.description ?? "모임 설명 없음")
                    .font(Design.body)
                
                CustomDisclosureGroup(
                    label: "멤버 (\(store.channelMembers.count))",
                    isExpanded: $store.isMemeberExpand) {
                        memberGridView()
                    }
                    .foregroundStyle(Design.black)
                
                channelSettingButtonView()
            }
            .padding(.horizontal, 16)
        }
        .task { store.send(.task) }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity)
        .customToolbar(
            title: "모임 설정",
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
                    LoadedImageView(urlString: member.profileImage ?? "", size: 44)
                    
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
                        text: "모임 편집",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.adminGetOutChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "모임에서 나가기",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.changeAdminButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "모임 관리자 변경",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
                Button {
                    store.send(.deleteChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "모임 삭제",
                        textColor: Design.red,
                        borderColor: Design.red
                    )
                }
            } else {
                Button {
                    store.send(.getOutChannelButtonTap)
                } label: {
                    RoundedBorderButton(
                        text: "모임에서 나가기",
                        textColor: Design.black,
                        borderColor: Design.black
                    )
                }
            }
        }
    }
    
    private func editChannelView() -> some View {
        VStack {
            SheetHeaderView(title: "모임 편집")
                .background(Design.white)
            ScrollView {
                VStack(spacing: 24) {
                    VStack {
                        CustomPhotoPicker(
                            selectedImages: $store.selectedImage,
                            maxSelectedCount: 1
                        ) {
                            if let images = store.selectedImage, let image = images.last {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: getScreenWidth()*0.5,
                                        height: getScreenWidth()*0.5
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundStyle(Design.darkGray)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(Design.gray)
                                        .frame(
                                            width: getScreenWidth()*0.5,
                                            height: getScreenWidth()*0.5
                                        )
                                    
                                    Image(systemName: "camera")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width:  getScreenWidth()*0.1,
                                            height: getScreenWidth()*0.1)
                                        .foregroundStyle(Design.white)
                                }
                                
                            }
                        }
                        Button(action: {
                            store.send(.deleteImageButtonTapped)
                        }, label: {
                            Text("이미지 초기화")
                                .font(Design.caption)
                                .foregroundStyle(Design.darkGray)
                        })
                        .padding(5)
                    }

                    TextFieldWithTitle(
                        title: "모임 이름",
                        placeholder: "모임 이름을 입력해주세요",
                        text: $store.title
                    )
                    TextFieldWithTitle(
                        title: "모임 설명",
                        placeholder: "모임 설명을 입력해주세요",
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
                    backgroundColor: store.buttonValid ? Design.mainSkyblue : Design.darkGray
                )
            }
            .disabled(!store.buttonValid)
            .padding([.horizontal, .bottom])
        }
        .background(Design.background)
    }
    
    private func changeAdminView(_ members: [Member]) -> some View {
        VStack {
            SheetHeaderView(title: "관리자 변경")
                .background(Design.white)
            ScrollView {
                LazyVStack {
                    ForEach(members, id: \.id) { member in
                        Button {
                            store.send(.changeAdminCellTap(member))
                        } label: {
                            HStack(spacing: 8) {
                                LoadedImageView(urlString: member.profileImage ?? "", size: 44)
                                VStack(alignment: .leading) {
                                    Text(member.nickname)
                                        .font(Design.bodyBold)
                                    Text(member.email)
                                        .font(Design.body)
                                        .foregroundStyle(Design.darkGray)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Design.background)
        .onAppear {
            if members.isEmpty { store.send(.channelEmpty) }
        }
        // 모임 관리자 변경
        .customAlert(
            isPresented: $store.isChangeAdminAlertPresented,
            title: "\(store.changeAdminTarget?.nickname ?? "선택한 유저 없음") 님을 관리자로 지정하시겠습니까?",
            message: """
            모임 관리자는 다음과 같은 권한이 있습니다.
            
            - 모임 이름 또는 설명 변경
            - 모임 삭제
            """,
            primaryButton: CustomAlert.AlertButton(title: "확인") {
                store.send(.changeAdminAction(store.changeAdminTarget))
            },
            secondaryButton: CustomAlert.AlertButton(title: "취소") {
                store.send(.changeAdminCancel)
            }
        )
        // 모임 관리자 변경 불가
        .customAlert(
            isPresented: $store.isChannelEmptyAlertPresented,
            title: "모임 관리자 변경 불가",
            message: "모임 멤버가 없어 관리자 변경을 할 수 없습니다.",
            primaryButton: CustomAlert.AlertButton(title: "확인") {
                store.send(.channelEmptyConfirmAction)
            }
        )
    }
}
