//
//  GatheringNavigationStack.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI
import UIKit

import ComposableArchitecture

struct GatheringNavigationStack<Content: View>: View {
    let gatheringImage: String
    let title: String
    let myProfile: MyProfileResponse?
    @State private var showProfile = false
    let content: Content
    
    init(
        gatheringImage: String,
        title: String,
        myProfile: MyProfileResponse?,
        @ViewBuilder content: () -> Content
    ) {
        self.gatheringImage = gatheringImage
        self.title = title
        self.myProfile = myProfile
        self.content = content()
    }
    
    var body: some View {
        WithPerceptionTracking {
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
                            if let profile = myProfile {
                                Button {
                                    showProfile = true
                                } label: {
                                    ProfileImageView(
                                        urlString: profile.profileImage ?? "",
                                        size: 32
                                    )
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.black, lineWidth: 2))
                                }
                            }
                        }
                    }
                    .navigationDestination(isPresented: $showProfile) {
                        if let profile = myProfile {
                            ProfileView(
                                store: Store(
                                    initialState: ProfileFeature.State(
                                        profileType: .me,
                                        nickname: profile.nickname,
                                        email: profile.email,
                                        profileImage: profile.profileImage ?? ""
                                    )
                                ) {
                                    ProfileFeature()
                                }
                            )
                        }
                    }
            }
        }
    }
}
