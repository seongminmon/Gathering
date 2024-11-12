//
//  ChannelAddView.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct ChannelAddView: View {
    @State private var channelName: String = ""
    @State private var channelDescription: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: "채널 생성")
            
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("채널 이름")
                        .font(.title2)
                    TextField("", text: $channelName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("채널 설명")
                        .font(.title2)
                    TextField("", text: $channelDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Spacer()
                
                // TODO: 컴포넌트 써야함
                Button(action: {
                }) {
                    Text("생성")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Design.green)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Design.background)
    }
}
