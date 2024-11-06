//
//  HomeView.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import SwiftUI

struct HomeView: View {
    let channels = Dummy.channels
    let users = Dummy.users
    
    @State private var isChannelExpanded = true
    @State private var isDMExpanded = true
    @State private var showingSheet = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 채널
                    CustomDisclosureGroup(
                        label: "채널",
                        isExpanded: $isChannelExpanded
                    ) {
                        channelListView()
                        makeAddButton(text: "채널 추가") {
                            showingSheet = true
                        }
                        .confirmationDialog("",
                                            isPresented: $showingSheet,
                                            titleVisibility: .hidden
                        ) {
                            Button("채널 생성") {
                                print("1")
                            }
                            Button("채널 추가") {
                                print("2")
                            }
                            Button("취소", role: .cancel) {}
                        }
                    }
                    .padding()
                    Divider()
                    
                    // DM
                    CustomDisclosureGroup(
                        label: "다이렉트 메시지",
                        isExpanded: $isDMExpanded
                    ) {
                        dmListView()
                    }
                    .padding()
                }
                .foregroundStyle(.black)
                Divider()
                makeAddButton(text: "팀원 추가") {
                    
                }
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 0))
            }
            FloatingActionButton {
                // TODO: -
                print("탭탭")
            }
        }
    }
    
    private func channelListView() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(channels, id: \.self) { channel in
                HStack {
                    ProfileImageView(
                        imageName: channel.unreadCount == nil ? "thin" : "hashTagthick",
                        size: 15
                    )
                    Button(action: {
                        // TODO: -
                    }) {
                        Text(channel.name)
                            .foregroundColor(
                                channel.unreadCount == nil ? Design.darkGray : Design.black
                            )
                            .font(channel.unreadCount == nil ? Design.body : Design.bodyBold)
                        Spacer()
                        if let count = channel.unreadCount {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
        }
    }
    
    private func dmListView() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(users) { user in
                HStack {
                    ProfileImageView(imageName: user.profileImage, size: 30)
                    Button(action: {
                        // TODO: -
                    }) {
                        Text(user.name)
                            .foregroundColor(
                                user.unreadCount == nil ? Design.darkGray : Design.black
                            )
                            .font(user.unreadCount == nil ? Design.body : Design.bodyBold)
                        Spacer()
                        if let count = user.unreadCount {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
            makeAddButton(text: "새 메시지 시작") {
                // TODO: -
            }
        }
    }
    
    private func makeAddButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(.plus)
                    .resizable()
                    .frame(width: 15, height: 15)
                Text(text)
                    .font(.body)
                Spacer()
            }
            .padding(.top)
            .foregroundColor(Design.darkGray)
        }
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
// TODO: extension 모을지 말지
extension View {
    func badge(
        backgroundColor: Color = Design.green,
        textColor: Color = Design.white
    ) -> some View {
        self
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .clipShape(Capsule())
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.pencil")
                .foregroundColor(Design.white)
                .font(.system(size: 25))
                .frame(width: 60, height: 60)
                .background(Design.green)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }
}
