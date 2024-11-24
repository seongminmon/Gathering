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
    @State private var showProfile = false
    @State var gatheringImage: String?
    @State var myprofileData: MyProfileResponse?
    let content: Content
    let title: String
    
    init(gatheringImage: String,
         title: String,
         myprofileData: MyProfileResponse? = nil,
         content: () -> Content) {
        self.content = content()
        self.title = title
        self.gatheringImage = gatheringImage
        self.myprofileData = myprofileData
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            ProfileImageView(urlString: gatheringImage ?? "", size: 32)
                            Text(title)
                                .font(Design.title1)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showProfile = true
                        } label: {
                            ProfileImageView(urlString: myprofileData?.profileImage ?? "", size: 32)
                        }
                    }
                }
                .navigationDestination(isPresented: $showProfile) {
                    ProfileView(
                        store: Store(
                            initialState: ProfileFeature.State(
                                profileType: .me,
                                nickname: myprofileData?.nickname ?? "오류",
                                email: myprofileData?.email ?? "오류"
                            )
                        ) {
                            ProfileFeature()
                        }
                    )
                }
                .task {
                   print("sf")
                }
        }
    }
}
