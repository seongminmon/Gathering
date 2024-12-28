//
//  ChannelChattingView.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import Combine
import SwiftUI
import PhotosUI

import ComposableArchitecture

struct ChannelChattingView: View {
    
    // TODO: - 키보드 올라올 때 채팅창 스크롤 내리기
    
    @Perception.Bindable var store: StoreOf<ChannelChattingFeature>
    @FocusState private var isFocused: Bool
    var keyboardSubscriber: AnyCancellable?
    @Environment(\.scenePhase) var scenePhase
    
    private var navigationTitle: String {
        let channelName = store.currentChannel?.name ?? ""
        let memberCount = store.currentChannel?.channelMembers?.count ?? 0
        return "\(channelName)  \(memberCount)"
    }
    
    var body: some View {
        WithPerceptionTracking {
            mainContent
        }
    }
    
    private var mainContent: some View {
        VStack {
            // 채팅 메시지 리스트
            chatListView
                .onTapGesture {
                    hideKeyboard()
                }
            // 채팅보내는 부분
            messageInputView
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .task { store.send(.task) }
        
        .onDisappear {
            // 뷰가 사라질 때 키보드 노티피케이션 구독 해제
            keyboardSubscriber?.cancel()
//            print("모임 채팅 뷰 - onDisappear")
//            store.send(.onDisappear)
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                store.send(.active)
            case .background:
                store.send(.background)
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .customToolbar(
            title: navigationTitle,
            leftItem: .init(icon: .chevronLeft) {
                store.send(.backButtonTap)
            },
            rightItem: .init(icon: .list) {
                store.send(.settingButtonTap(store.currentChannel))
            }
        )
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(store.scrollViewID, anchor: .bottom)
        }
    }
}
extension ChannelChattingView {
    
    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(store.message) { message in
                        if message.isMine {
                            myMessageView(message: message)
                        } else {
                            othersMessageView(message: message)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .id(store.scrollViewID)
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                proxy
                    .scrollTo(store.scrollViewID, anchor: .bottom)
            }
            // 메시지 추가 시 자동 스크롤
            .onChange(of: store.message.count) { _ in
                withAnimation {
                    proxy.scrollTo(store.scrollViewID, anchor: .bottom)
                }
            }
        }
    }
    private func myMessageView(message: ChattingPresentModel) -> some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .bottom) {
                Spacer()
                
                let date = message.date.createdAtToDate() ?? Date()
                let dateString = date.isToday ?
                date.toString(.todayChat) :
                date.toString(.pastChat)
                
                Text(dateString)
                    .font(Design.caption2)
                    .foregroundStyle(Design.darkGray)
                
                VStack(alignment: .trailing) {
                    if let text = message.text, !text.isEmpty {
                        Text(text)
                            .font(Design.body)
                            .padding(9)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Design.skyblue)
                            )
                    }
                    if !message.imageNames.isEmpty {
                        NavigationLink {
                            ImageDetailView(imageNames: message.imageNames)
                        } label: {
                            ChattingImageView(imageNames: message.imageNames)
                        }
                    }
                    
                }
            }
        }
        .padding(.top, 5)
        .frame(maxWidth: .infinity)
    }
    
    private func othersMessageView(message: ChattingPresentModel) -> some View {
        HStack(alignment: .top) {
            LoadedImageView(urlString: message.profile ?? "defaultProfile", size: 34)
                .wrapToButton {
                    store.send(.profileButtonTap(message.user))
                }
            VStack(alignment: .leading) {
                Text(message.name)
                    .font(Design.caption)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        if let text = message.text, !text.isEmpty {
                            Text(text)
                                .font(Design.body)
                                .padding(9)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Design.chatBackground)
                                )
                        }
                        if !message.imageNames.isEmpty {
                            NavigationLink {
                                ImageDetailView(imageNames: message.imageNames)
                            } label: {
                                ChattingImageView(imageNames: message.imageNames)
                            }
                        }
                    }
                    
                    let date = message.date.createdAtToDate() ?? Date()
                    let dateString = date.isToday
                    ? date.toString(.todayChat)
                    : date.toString(.pastChat)
                    Text(dateString)
                        .font(Design.caption2)
                        .foregroundStyle(Design.darkGray)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 5)
    }
}

extension ChannelChattingView {
    private var messageInputView: some View {
        HStack {
            HStack(alignment: .bottom) {
                CustomPhotoPicker(
                    selectedImages: $store.selectedImages,
                    maxSelectedCount: 5
                ) {
                    Image(systemName: Design.plus)
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundStyle(Design.darkGray)
                }
                
                VStack(alignment: .leading) {
                    dynamicHeigtTextField()
                    if let images = store.selectedImages, !images.isEmpty {
                        selectePhotoView(images: images)
                    }
                }
//                .onAppear {
//                    // 뷰가 나타날 때 자동으로 TextField에 포커스
//                    isFocused = true
//                }
//
                Button {
                    store.send(.sendButtonTap)
                } label: {
                    Image(systemName: Design.paperplane)
                        .font(.system(size: 20))
                        .foregroundStyle(store.messageButtonValid
                                         ? Design.mainSkyblue : Design.darkGray)
                }
                .disabled(!store.messageButtonValid)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Design.background)
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
    
    private func dynamicHeigtTextField() -> some View {
        TextField("메시지를 입력하세요", text: $store.messageText, axis: .vertical)
            .focused($isFocused)  // TextField에 focus 바인딩
            .onChange(of: isFocused) { newValue in
                store.isTextFieldFocused = newValue
            }
            .onChange(of: store.isTextFieldFocused) { newValue in
                isFocused = newValue
            }
            .lineLimit(1...5)
            .background(Color.clear)
            .font(Design.body)
    }
    
    private func selectePhotoView(images: [UIImage]) -> some View {
        LazyHGrid(rows: [GridItem(.fixed(50))], spacing: 12) {
            ForEach(images, id: \.self) { image in
                photoItem(image: image)
            }
        }
        .frame(height: 55)
    }
    
    private func photoItem(image: UIImage) -> some View {
        Button {
            store.send(.imageDeleteButtonTap(image))
        } label: {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(.rect(cornerRadius: 8))
                
                Image(systemName: Design.xmarkCircle)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Design.black)
                    .background(
                        Circle()
                            .size(width: 20, height: 20)
                            .foregroundStyle(Design.white)
                    )
                    .offset(x: 20, y: -20)
            }
        }
    }
}
