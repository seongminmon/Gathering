//
//  GatheringNavigationStack.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct GatheringNavigationStack<Content: View>: View {
    let content: Content
    let title: String
    let gatheringImage: String
    let profileImage: String
    
    init(gatheringImage: String?,
         title: String,
         profileImage: String?,
         content: () -> Content) {
        self.content = content()
        self.title = title
        self.gatheringImage = gatheringImage ?? "bird"
        self.profileImage = profileImage ?? "bird"
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            ProfileImageView(urlString: gatheringImage, size: 32)
                            Text(title)
                                .font(Design.title1)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        ProfileImageView(urlString: profileImage, size: 30)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.black, lineWidth: 2)
                            )
                    }
                }
        }
    }
}
