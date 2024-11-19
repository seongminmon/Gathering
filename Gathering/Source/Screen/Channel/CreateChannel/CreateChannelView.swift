//
//  CreateChannelView.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

import ComposableArchitecture

struct CreateChannelView: View {
    @Perception.Bindable var store: StoreOf<CreateChannelFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                SheetHeaderView(title: "채널 생성")
                
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("채널 이름")
                            .font(.title2)
                        TextField("", text: $store.channelName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("채널 설명")
                            .font(.title2)
                        TextField("", text: $store.channelDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer()
                    
                    Button(action: {
                        store.send(.saveButtonTapped)
                    }) {
                        Text("생성")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(store.isValid ? Design.green : Design.darkGray)
                            .cornerRadius(8)
                    }
                    .disabled(!store.isValid)
                }
                .padding()
            }
            .background(Design.background)
        }
    }
}
