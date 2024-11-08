//
//  InviteMemberView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

struct InviteMemberView: View {
    @State private var userEmail: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: "팀원 초대")
            
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("채널 이름")
                        .font(.title2)
                    TextField("", text: $userEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Spacer()
                
                // TODO: 컴포넌트 써야함
                Button(action: {
                }) {
                    Text("초대 보내기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.background)
    }
}
