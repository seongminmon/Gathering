//
//  DMChattingView.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture
import Combine

struct DMChattingView: View {
    
    @Perception.Bindable var store: StoreOf<DMChattingFeature>
    var keyboardSubscriber: AnyCancellable?
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        WithPerceptionTracking {
            mainContent
        }
    }
}

extension DMChattingView {
    private var mainContent: some View {
        VStack {
            // 채팅 리스트 부분
            chattingListView()
            // 채팅보내는 부분
            messageInputView()
                .onTapGesture {
                    // 화면을 탭할 때 키보드 내리기
                    hideKeyboard()
                }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .task { store.send(.task) }
        
        .onDisappear {
//            print("DM 채팅 뷰 - onDisappear")
//            store.send(.onDisappear)
            // 뷰가 사라질 때 키보드 노티피케이션 구독 해제
            keyboardSubscriber?.cancel()
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
            title: store.dmsRoomResponse.user.nickname,
            leftItem: .init(icon: .chevronLeft) {
                store.send(.backButtonTap)
            }
        )
    }
}

extension DMChattingView {
    
    private func chattingListView() -> some View {
        // 채팅 메시지 리스트
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(store.message) { message in
                        messageListView(message: message)
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
            .onChange(of: store.message.count) { _ in
                // 메시지 추가 시 자동 스크롤
                withAnimation {
                    proxy.scrollTo(store.scrollViewID, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private func messageListView(message: ChattingPresentModel) -> some View {
        if message.isMine {
            myMessageView(message: message)
                .padding(.top, 5)
        } else {
            othersMessageView(message: message)
                .padding(.top, 5)
        }
    }
    
    private func myMessageView(message: ChattingPresentModel) -> some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .bottom) {
                Spacer()
                let date = message.date.createdAtToDate() ?? Date()
                let dateString = date.isToday
                ? date.toString(.todayChat)
                : date.toString(.pastChat)
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
        .frame(maxWidth: .infinity)
    }
    
    private func othersMessageView(message: ChattingPresentModel) -> some View {
        HStack(alignment: .top) {
            LoadedImageView(urlString: message.profile ?? "defaultProfile",
                             size: 34).wrapToButton {
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
                                    RoundedRectangle(cornerRadius: 8) // 둥근 모서리
                                        .fill(Design.chatBackground) // 배경색 설정
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
    }
}
extension DMChattingView {
    
    private func dynamicHeigtTextField() -> some View {
        VStack {
            TextField("메세지를 입력하세요", text: $store.messageText, axis: .vertical)
                .lineLimit(1...5)
                .background(Color.clear)
                .font(Design.body)
        }
    }
    
    private func messageInputView() -> some View {
        HStack {
            // 입력 뷰
            HStack(alignment: .bottom) {
                // 이미지 선택 버튼
                CustomPhotoPicker(
                    selectedImages: $store.selectedImages,
                    maxSelectedCount: 5
                ) {
                    Image(systemName: Design.plus)
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundStyle(Design.darkGray)
                }
                .disabled(store.selectedImages?.count == 5)
                
                VStack(alignment: .leading) {
                    // 메시지 입력 필드
                    dynamicHeigtTextField()
                    if let images = store.selectedImages, !images.isEmpty {
                        selectePhotoView(images: images)
                    }
                }
                // 전송버튼
                Button {
                    // 메세지 전송 로직
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
    
    private func selectePhotoView(images: [UIImage]?) -> some View {
        
        LazyHGrid(rows: [GridItem(.fixed(50))], spacing: 12, content: {
            // 이미지넣기
            if let images = store.selectedImages {
                ForEach(images, id: \.self) { image in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 44, height: 44)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Button(action: {
                            store.send(.imageDeleteButtonTap(image))
                        }, label: {
                            Image(systemName: Design.xmarkCircle)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Design.black)
                                .background(
                                    Circle().size(width: 20, height: 20)
                                        .foregroundStyle(Design.white)
                                )
                                .offset(x: 20, y: -20)
                        })
                        
                    }
                    
                }
            }
            
        })
        .frame(height: 55)
    }
}
