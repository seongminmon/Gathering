//
//  ChannelExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

struct ChannelExploreView: View {
    var body: some View {
        let channels = Dummy.channels
        SheetHeaderView(title: "채널 탐색")
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(channels, id: \.id) { channel in
                    HStack(spacing: 12) {
                        ProfileImageView(imageName: "hashTagthick",
                                         size: 18)
                        
                        Button(action: {
                            // TODO: -
                        }) {
                            Text(channel.name)
                                .font(.title2)
                                .tint(.black)
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

