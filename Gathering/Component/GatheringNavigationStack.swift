//
//  GatheringNavigationStack.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct GatheringNavigationStack<Content: View>: View {
    let content: Content
    let gatheringImage: String
    let profileImage: String
    
    init(gatheringImage: String?, profileImage: String?, @ViewBuilder content: () -> Content) {
        self.content = content()
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
                            Text("iOS Developers Study")
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
