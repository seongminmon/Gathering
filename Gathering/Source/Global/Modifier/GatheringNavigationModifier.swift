//
//  GatheringNavigationModifier.swift
//  Gathering
//
//  Created by 김성민 on 12/1/24.
//

import SwiftUI

import ComposableArchitecture

struct GatheringNavigationModifier: ViewModifier {
    let gatheringImage: String
    let title: String
    let myProfile: MyProfileResponse?
    @State private var showProfile = false
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
//                    HStack {
//                        LoadedImageView(urlString: gatheringImage, size: 32)
                        Text("Gathering")
                            .font(Design.logoTitle)
                            .foregroundStyle(Design.mainSkyblue)
//                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let profile = myProfile {
                        Button {
                            showProfile = true
                        } label: {
                            LoadedImageView(
                                urlString: profile.profileImage ?? "",
                                size: 32
                            )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Design.mainSkyblue, lineWidth: 3))
                        }
                    }
                }
            }
        // TODO: - WithPerceptionTracking 오류 발생 후보
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

extension View {
    func asGatheringNavigationModifier(
        gatheringImage: String,
        title: String,
        myProfile: MyProfileResponse?
    ) -> some View {
        self
            .modifier(
                GatheringNavigationModifier(
                    gatheringImage: gatheringImage,
                    title: title,
                    myProfile: myProfile
                )
            )
    }
}
