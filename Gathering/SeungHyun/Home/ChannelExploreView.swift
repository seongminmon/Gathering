//
//  ChannelExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

struct ChannelExploreView: View {
    
    @State private var showCustomAlert = false
    @State private var selectedChannel: Channel?
    let channels = Dummy.channels
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SheetHeaderView(title: "채널 탐색")
                makeScrollView()
            }
            .customAlert(
                isPresented: $showCustomAlert,
                title: "채널 참여",
                message: "[\(selectedChannel?.name ?? "")] 채널에 참여 하시겠습니까?",
                primaryButton: .init(
                    title: "확인",
                    action: {
                        showCustomAlert = false
                    }
                ),
                secondaryButton: .init(
                    title: "취소",
                    action: {
                        showCustomAlert = false
                    }
                )
            )
        }
    }
    private func makeScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(channels, id: \.id) { channel in
                    HStack(spacing: 12) {
                        ProfileImageView(imageName: "hashTagthick",
                                         size: 18)
                        
                        Button(action: {
                            showCustomAlert = true
                            selectedChannel = channel
                        }) {
                            Text(channel.name)
                                .font(Design.title2)
                                .tint(Design.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 20)
        }
    }
}
