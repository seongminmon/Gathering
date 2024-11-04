//
//  ChannelView.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import SwiftUI

struct ChannelListView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Text("iOS Developers Study")
                    .font(.headline)
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
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    
                    // Direct Messages Section
                    DisclosureGroup {
                        DirectMessageList()
                    } label: {
                        Text("다이렉트 메시지")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ChannelList: View {
    let channels = ["일반", "스우 뽀개기", "앱스토어 홍보", "오프라운지", "TIL"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(channels, id: \.self) { channel in
                HStack {
                    Text("#")
                        .foregroundColor(.gray)
                    Text(channel)
                    Spacer()
                    if channel == "오프라운지" {
                        Text("99")
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
                    Text("채널 추가")
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.vertical)
    }
}

struct DirectMessageList: View {
    struct DMUser: Identifiable {
        let id = UUID()
        let name: String
        let unreadCount: Int?
    }
    
    let users: [DMUser] = [
        DMUser(name: "핑퐁스지킹이", unreadCount: nil),
        DMUser(name: "Hue", unreadCount: 8),
        DMUser(name: "테스트 코드 짜는 새싹이", unreadCount: 1),
        DMUser(name: "Jack", unreadCount: nil)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(users) { user in
                HStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 32, height: 32)
                    Text(user.name)
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
