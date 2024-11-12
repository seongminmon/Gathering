//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

@main
struct GatheringApp: App {
    
    @State private var toast: Toast?
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    // Toast NotificationCenter 구독
                    NotificationCenter.default.addObserver(
                        forName: .showToast,
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let toast = notification.toast {
                            self.toast = toast
                            ToastWindowManager.shared.showToast(toast: self.$toast)
                        }
                    }
                }
        }
    }
}
