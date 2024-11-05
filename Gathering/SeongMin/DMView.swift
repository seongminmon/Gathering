//
//  DMView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct DMView: View {
    
    @State private var list: [String] = []
    
    var body: some View {
        VStack {
            if list.isEmpty {
                emptyMemberView()
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10) {
                        userCell()
                    }
                }
                ScrollView {
                    LazyVStack(spacing: 20, content: {
                        ForEach(list, id: \.self) { item in
                            Text("\(item)")
                        }
                    })
                }
            }
        }
        // 네비게이션 바
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "star")
                        .profileImageStyle()
                    Text("Direct Message")
                        .font(.title1)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                profileButton()
            }
        }
    }
    
    private func profileButton() -> some View {
        Button {
            print("프로필 버튼 탭")
        } label: {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .background(.gray)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                )
        }
    }
    
    private func emptyMemberView() -> some View {
        VStack(spacing: 20) {
            Text("워크스페이스에 \n멤버가 없어요.")
                .font(.title1)
            Text("새로운 팀원을 초대해보세요.")
                .font(.body)
            Button("팀원 초대하기") {
                print("팀원 초대 버튼 탭")
                list.append("asdfasdf")
            }
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 269, height: 44)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func userCell() -> some View {
        VStack(spacing: 4) {
            Image(systemName: "star")
                .profileImageStyle()
                .frame(width: 44, height: 44)
            Text("asdf")
        }
    }
}

extension Image {
    func profileImageStyle() -> some View {
        self
            .resizable()
            .frame(width: 32, height: 32)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
