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
                            ProfileImageView(imageName: gatheringImage, size: 32)
                            Text(title)
                                .font(Design.title1)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Design.gray)
                            .overlay(
                                Circle()
                                    .stroke(.black, lineWidth: 2)
                            )
                    }
                }
        }
    }
}
