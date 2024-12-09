//
//  ChannelChattingView.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture
import Combine

struct ChannelChattingView: View {
    
    @Perception.Bindable var store: StoreOf<ChannelChattingFeature>
    var keyboardSubscriber: AnyCancellable?
    
    var body: some View {
        WithPerceptionTracking {
            mainContent
        }
    }
    
    private var mainContent: some View {
        VStack {
            // 채팅 메시지 리스트
            chatListView
            // 채팅보내는 부분
            messageInputView
        }
        .navigationBarBackButtonHidden()
        .task { store.send(.task) }
        .onTapGesture {
            hideKeyboard()
        }
        .onDisappear {
            // 뷰가 사라질 때 키보드 노티피케이션 구독 해제
            keyboardSubscriber?.cancel()
//            print("채널 채팅 뷰 - onDisappear")
//            store.send(.onDisappear)
        }
        .customToolbar(
            title: store.currentChannel?.name ?? "",
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
//                scrollToBottom(proxy: proxy)
            }
            // 메시지 추가 시 자동 스크롤
            .onChange(of: store.message.count) { _ in
                withAnimation {
                    proxy.scrollTo(store.scrollViewID, anchor: .bottom)
                }
//                scrollToBottom(proxy: proxy)
            }
        }
    }
    private func myMessageView(message: ChattingPresentModel) -> some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .bottom) {
                Spacer()
                Text(message.date.toString(.todayChat))
                    .font(Design.caption2)
                    .foregroundStyle(Design.darkGray)
                VStack(alignment: .trailing) {
                    if let text = message.text, !text.isEmpty {
                        Text(text)
                            .font(Font.body)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Design.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Design.gray, lineWidth: 1)
                            )
                    }
                    if !message.imageNames.isEmpty {
                        ChattingImageView(imageNames: message.imageNames)
                    }
                }
            }
        }
        .padding(.top, 5)
        .frame(maxWidth: .infinity)
    }
    
    private func othersMessageView(message: ChattingPresentModel) -> some View {
        HStack(alignment: .top) {
            LoadedImageView(urlString: message.profile ?? "bird", size: 34)
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
                                .font(Font.body)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.gray, lineWidth: 1)
                                )
                        }
                        if !message.imageNames.isEmpty {
                            ChattingImageView(imageNames: message.imageNames)
                        }

                    }
                    Text(message.date.toString(.todayChat))
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
                ChattingPhotoPicker(selectedImages: $store.selectedImages) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundColor(Design.darkGray)
                }
                
                VStack(alignment: .leading) {
                    dynamicHeigtTextField()
                    if let images = store.selectedImages, !images.isEmpty {
                        selectePhotoView(images: images)
                    }
                }
                
                Button {
                    store.send(.sendButtonTap)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(store.messageButtonValid
                                       ? Design.green : Design.darkGray)
                }
                .disabled(!store.messageButtonValid)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Design.background)
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
    
    private func dynamicHeigtTextField() -> some View {
        TextField("메세지를 입력하세요", text: $store.messageText, axis: .vertical)
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
        ZStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 44, height: 44)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button {
                store.send(.imageDeleteButtonTap(image))
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Design.black)
                    .background(
                        Circle()
                            .size(width: 20, height: 20)
                            .foregroundColor(Design.white)
                    )
                    .offset(x: 20, y: -20)
            }
        }
    }

}
