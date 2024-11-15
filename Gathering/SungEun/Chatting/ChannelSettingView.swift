//
//  ChannelSettingView.swift
//  Gathering
//
//  Created by 여성은 on 11/15/24.
//

import SwiftUI

struct ChannelSettingView: View {
    
    var channelInfo = ChannelDummy.channelInfo
    @State private var isMemeberExpand = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(channelInfo.name)
                    .font(Design.title2)
                
                Text(channelInfo.description ?? "")
                    .font(Design.body)
                
                CustomDisclosureGroup(
                    label: "멤버 (\(channelInfo.channelMembers?.count ?? 0))",
                    isExpanded: $isMemeberExpand) {
                    memberGridView()
                }
                .foregroundColor(Design.black)
                
                Button {
                    //채널 편집 시트
                } label: {
                    channelSettingButton(title: "채널 편집")
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .customToolbar(title: "채널 설정",
                       leftItem: .init(icon: "chevron.left", action: {
            print("backbutton clicked")
        }))
        
    }
    func channelSettingButton(title: String) -> some View {
        Text(title)
            .asButtonStyle(foregroundColor: Design.black, backgroundColor: Design.white)
            .border(Design.black)
           
    }
    func memberGridView() -> some View {
        VStack {
            let columns = [
                //추가 하면 할수록 화면에 보여지는 개수가 변함
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            LazyVGrid(columns: columns, spacing: 10) {
                if let members = channelInfo.channelMembers {
                    ForEach(members, id:  \.user_id) { member in
                        VStack(alignment: .center) {
                            Image(member.profileImage ?? "bird")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(member.nickname)
                                .font(Design.body)
                                .foregroundStyle(Design.darkGray)
                        }
                    }
                }
            
            }
        }
        .padding(.vertical, 16)
        
    }
}

//#Preview {
//    ChannelSettingView()
//}

struct ChannelDummy {
    static let channelInfo = ChannelResponse(
        channel_id: "dfa",
        name: "#그냥 떠들고 싶을 때",
        description: "안녕하세요 새싹 여러분? 심심하셨죠? 이 채널은 나머지 모든 것을 위한 채널이에요. 팀원들이 농담하거나 순간적인 아이디어를 공유하는 곳이죠! 마음껏 즐기세요",
        coverImage: nil,
        owner_id: "sungeun",
        createdAt: "dfs",
        channelMembers: ChannelDummy.member
    )
    
    static let member: [MemberResponse]  = [
        MemberResponse(user_id: "sungeun", email: "dsf", nickname: "dfa", profileImage: "bird"),
        MemberResponse(user_id: "dfad", email: "dsf", nickname: "123", profileImage: "bird"),
        MemberResponse(user_id: "sunsfdgeun", email: "dsf", nickname: "dsf", profileImage: "bird2"),
        MemberResponse(user_id: "ㄴㅇㄹㅁ", email: "dsf", nickname: "gre", profileImage: "bird3"),
        MemberResponse(user_id: "ㅁㄴㅇㅎ", email: "dsf", nickname: "dfa", profileImage: "bird"),
        MemberResponse(user_id: "ㅜㅠㅍ", email: "dsf", nickname: "123", profileImage: "bird"),
        MemberResponse(user_id: "ㅔ", email: "dsf", nickname: "dsf", profileImage: "bird2"),
        MemberResponse(user_id: "ㅋ", email: "dsf", nickname: "gre", profileImage: "bird3"),
        MemberResponse(user_id: "5", email: "dsf", nickname: "dfa", profileImage: "bird"),
        MemberResponse(user_id: "dfad", email: "dsf", nickname: "123", profileImage: "bird"),
        MemberResponse(user_id: "ㅜ", email: "dsf", nickname: "dsf", profileImage: "bird2"),
        MemberResponse(user_id: "ㅁ", email: "dsf", nickname: "gre", profileImage: "bird3"),
        MemberResponse(user_id: "ㄴ", email: "dsf", nickname: "dfa", profileImage: "bird"),
        MemberResponse(user_id: "ㅇ", email: "dsf", nickname: "123", profileImage: "bird"),
        MemberResponse(user_id: "ㄹ", email: "dsf", nickname: "dsf", profileImage: "bird2"),
        MemberResponse(user_id: "ㅍ", email: "dsf", nickname: "gre", profileImage: "bird3")
    ]
}
