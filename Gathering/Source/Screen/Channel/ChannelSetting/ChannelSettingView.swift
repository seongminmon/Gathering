//
//  ChannelSettingView.swift
//  Gathering
//
//  Created by 여성은 on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

struct ChannelSettingView: View {
    
    // 채널 채팅 화면에서 메뉴 버튼 클릭시 전환되는 화면
    // 이전 화면에서 채널에 대한 정보 전달
    
    // TODO: - 뷰
    // 채널 이름
    // 채널 설명
    // 채널 멤버 리스트
    
    // 채널 관리자 여부에 따라 다른 버튼 표시
    // 아닌 경우
    // >> 채널에서 나가기
    // 관리자인 경우
    // >> 채널 편집, 채널에서 나가기, 채널 관리자 변경, 채널 삭제
    
    // TODO: - 화면 이동
    // (네비게이션) 멤버 셀 선택 >> 다른 유저 프로필
    // (시트) 채널 편집 >> 채널 편집 화면
    // (얼럿) 채널에서 나가기 >> 채널 퇴장 화면
    // (시트) 채널 관리자 변경 >> 채널 관리자 변경 화면
    // (얼럿) 채널 삭제 >> 채널 삭제 화면
    // 뒤로가기 >> dismiss
    
    @Perception.Bindable var store: StoreOf<ChannelSettingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(store.currentChannel?.name ?? "채널명 없음")
                        .font(Design.title2)
                        .padding(.vertical, 16)
                    
                    Text(store.currentChannel?.description ?? "채널 설명 없음")
                        .font(Design.body)
                    
                    CustomDisclosureGroup(
                        label: "멤버 (\(store.currentChannel?.channelMembers?.count ?? 0))",
                        isExpanded: $store.isMemeberExpand) {
                            memberGridView()
                        }
                        .foregroundColor(Design.black)
                    
                    channelSettingButtonView()
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .customToolbar(
                title: "채널 설정",
                leftItem: .init(
                    icon: .chevronLeft,
                    action: { print("backbutton clicked") }
                )
            )
            // 채널 편집 화면
            .sheet(isPresented: $store.isEditChannelViewPresented) {
                EditChannelView()
            }
            // 관리자 변경 화면
            .sheet(isPresented: $store.isChangeAdminViewPresented) {
                ChangeAdminView()
            }
            // 채널 삭제
            .customAlert(
                isPresented: $store.idDeleteChannelAlertPresented,
                title: "채널 삭제",
                message: ""
            )
            // 채널 나가기 (관리자)
            .customAlert(
                isPresented: $store.isAdminGetOutChannelAlertPresented,
                title: "채널 나가기 (관리자)",
                message: ""
            )
            // 채널 나가기
            .customAlert(
                isPresented: $store.isGetOutChannelAlertPresented,
                title: "채널 나가기",
                message: ""
            )
        }
    }
    
    private func memberGridView() -> some View {
        VStack {
            let columns = [
                //추가 하면 할수록 화면에 보여지는 개수가 변함
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            LazyVGrid(columns: columns, spacing: 10) {
                if let members = store.currentChannel?.channelMembers {
                    ForEach(members, id:  \.user_id) { member in
                        VStack(alignment: .center) {
                            ProfileImageView(urlString: member.profileImage ?? "", size: 44)
                            Text(member.nickname)
                                .font(Design.body)
                                .foregroundStyle(Design.darkGray)
                        }
                    }
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
}

struct EditChannelView: View {
    var body: some View {
        Text("EditChannelView")
    }
}

struct ChangeAdminView: View {
    var body: some View {
        Text("ChangeAdminView")
    }
}
