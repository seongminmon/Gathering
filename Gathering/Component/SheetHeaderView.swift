//
//  SheetHeaderView.swift
//  Gathering
//
//  Created by dopamint on 11/7/24.
//

import SwiftUI

// MARK: 네비게이션을 쓰지않는 sheet뷰 상단에 넣어주세요 -
struct SheetHeaderView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 15)
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(.close)
                        .foregroundColor(.black)
                        .font(.title2)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                
                Spacer()
                
                Color.clear
                    .frame(width: 17)
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 10)
            Divider()
        }
        .frame(height: 60)
        .background(Design.white)
    }
}
