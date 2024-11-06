//
//  GatheringNavigationStack.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct GatheringNavigationStack<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            ProfileImageView(imageName: "bird", size: 35)
                            Text("iOS Developers Study")
                                .font(Design.title1)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "person.circle.fill")
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
