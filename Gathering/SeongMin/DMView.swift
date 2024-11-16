//
//  DMView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct DMView: View {
    
    @Perception.Bindable var store: StoreOf<DMFeature>
    
    var body: some View {
        WithPerceptionTracking {
            GatheringNavigationStack(gatheringImage: "bird2", title: "짹사모", profileImage: "bird2") {
                // "Direct Message" (네비게이션 타이틀)
                VStack {
                    // MARK: - tca bind test
//                    TextField("닉네임 입력", text: $store.nickname)
                    
                    // MARK: - tca dependency network test
//                    Button {
//                        store.send(.networkButtonTap)
//                    } label: {
//                        RoundedButton(text: "네트워크 테스트",
//                                      foregroundColor: Design.white,
//                                      backgroundColor: Design.green)
//                    }
                    
                    // MARK: - toast test
//                    Button {
//                        store.send(.toastButtonTap)
//                    } label: {
//                        ContinueEmailButton()
//                    }
                    
                    if store.chattingList.isEmpty {
                        emptyMemberView()
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(store.userList, id: \.self) { item in
                                    userCell(user: item)
                                }
                            }
                            .frame(height: 100)
                            .padding(.horizontal, 20)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 20, content: {
                                ForEach(store.chattingList, id: \.self) { item in
                                    chattingCell(data: item)
                                }
                            })
                        }
                    }
                    Spacer()
                }
            }
               
        }
    }
    
    private func emptyMemberView() -> some View {
        VStack(spacing: 20) {
            Text("워크스페이스에 \n멤버가 없어요.")
                .font(Design.title1)
            Text("새로운 팀원을 초대해보세요.")
                .font(.body)
            Button("팀원 초대하기") {
                print("팀원 초대 버튼 탭")
                store.send(.profileButtonTap)
            }
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 269, height: 44)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func userCell(user: DMUser) -> some View {
        VStack(spacing: 4) {
            ProfileImageView(imageName: user.profileImage, size: 44)
            Text(user.name)
                .font(Design.body)
                .frame(width: 44)
                .lineLimit(1)
        }
    }
    
    private func chattingCell(data: DMUser) -> some View {
        HStack(spacing: 4) {
            ProfileImageView(imageName: data.profileImage, size: 34)
            VStack(spacing: 4) {
                Text(data.name)
                    .font(Design.body)
                Text(data.name)
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
            }
            Spacer()
            VStack(spacing: 4) {
                Text("PM 11:23")
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
                EmptyView().badge(10)
            }
        }
        .padding(.horizontal, 16)
    }
}
