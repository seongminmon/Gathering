//
//  ChannelView.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import SwiftUI

struct ChannelListView: View {
    @State private var selectedTab = 0
    @State private var isChannelExpanded = true
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                RoundedIconImageView(imageName: "bird")
                Text("iOS Developers Study")
                    .font(Font.title1)
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            .padding()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Channel Section
                    DisclosureGroup {
                        ChannelList()
                    } label: {
                        Text("채널")
                            .font(Font.title2)
                    }
                    .padding(.horizontal)
                    
                    // Direct Messages Section
                    CustomDisclosureGroup(
                        label: "채널",
                        isExpanded: $isChannelExpanded
                    ) {
                        ChannelList()
                    }
                    .padding()
                }
                .foregroundStyle(.black)
            }
        }
    }
}

struct ChannelList: View {
    let channels: [Channel] = [Channel(name: "일반", unreadCount: nil),
                               Channel(name: "스유 뽀개기", unreadCount: nil),
                               Channel(name: "앱스토어 홍보", unreadCount: nil),
                               Channel(name: "오프라운지", unreadCount: 99),
                               Channel(name: "TIL", unreadCount: nil)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(channels, id: \.self) { channel in
                HStack {
                    Text("#")
                        .foregroundColor(.gray)
                    Text(channel.name)
                        .foregroundColor(channel.unreadCount == nil ? .gray : .black)
                        .font(channel.unreadCount == nil ? .body : .bodyBold)
                    Spacer()
                    if let channel = channel.unreadCount {
                        Text("99")
                            .font(Font.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus")
                    Text("채널 추가")
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.vertical)
    }
}

struct DirectMessageList: View {
    
    let users: [DMUser] = [
        DMUser(profileImage: "bird", name: "캠퍼스지킴이", unreadCount: nil),
        DMUser(profileImage: "bird2", name: "Hue", unreadCount: 8),
        DMUser(profileImage: "bird3", name: "테스트 코드 짜는 새싹이", unreadCount: 1),
        DMUser(profileImage: "bird4", name: "Jack", unreadCount: nil)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(users) { user in
                HStack {
                    RoundedIconImageView(imageName: user.name)
                    Text(user.name)
                        .foregroundColor(user.unreadCount == nil ? .darkGray : .black)
                        .font(user.unreadCount == nil ? .body : .bodyBold)
                    Spacer()
                    if let count = user.unreadCount {
                        Text("\(count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus")
                    Text("새 메시지 시작")
                }
                .foregroundColor(.gray)
            }
            Divider()
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus")
                    Text("팀원 추가")
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.vertical)
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelListView()
    }
}
struct CustomDisclosureGroup<Content: View>: View {
    let content: Content
    let label: String
    @Binding var isExpanded: Bool
    
    init(label: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.label = label
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(label)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(), value: isExpanded)
                }
            }
            
            if isExpanded {
                content
                    .padding(.leading)
            }
        }
    }
}
