//
//  SettingView.swift
//  Gathering
//
//  Created by dopamint on 11/20/24.
//

import SwiftUI

import ComposableArchitecture

struct SettingView: View {
//    let store: StoreOf<AppFeature>
    
    var body: some View {
        List {
            Button("로그아웃") {
                Notification.changeRoot(.fail)
//                store.send(.logout, animation: .default)
            }
            .foregroundColor(.red)
        }
        .navigationTitle("설정")
    }
}
