//
//  ChattingView.swift
//  Gathering
//
//  Created by 여성은 on 11/5/24.
//

import SwiftUI

import PhotosUI
import Combine
import Alamofire

struct ChattingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var messageText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var messages: [ChattingPresentModel] = [
//        ChatMessage(name: "지수", text: "아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘", images: [], imageNames: ["bird"], isMine: false, profile: "bird"),
//        ChatMessage(name: "아라", text: "그래그래 사진 보내줘~", images: [], imageNames: nil, isMine: false, profile: "bird2"),
//        ChatMessage(name: "나야나", text: "아직 못보내~....", images: [], imageNames: nil, isMine: true, profile: "bird3"),
//        ChatMessage(name: "성은", text: "^^>....", images: [], imageNames: nil, isMine: false, profile: "bird3")
        
    ]
    @State private var scrollViewID = UUID()
    @State private var keyboardHeight: CGFloat = 0 // 키보드 높이 상태 저장
    
    private var keyboardSubscriber: AnyCancellable?
    
    var body: some View {
        NavigationStack {
            VStack {
                // 채팅 메시지 리스트
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                            }
                        }
                        .padding(.horizontal, 20)
                        .id(scrollViewID)
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        proxy
                            .scrollTo(scrollViewID, anchor: .bottom)
                    }
                    .onChange(of: messages.count) { _ in
                        // 메시지 추가 시 자동 스크롤
                        withAnimation {
                            proxy.scrollTo(scrollViewID, anchor: .bottom)
                        }
                    }
                }
                messageInputView()
            }
            .onTapGesture {
                // 화면을 탭할 때 키보드 내리기
                hideKeyboard()
            }
            .onDisappear {
                // 뷰가 사라질 때 키보드 노티피케이션 구독 해제
                keyboardSubscriber?.cancel()
            }
            .customToolbar(title: "#모야모여모여랏",
                           leftItem: .init(icon: .chevronLeft) {
                // TODO: 스와이프 제스쳐 살리는법??
                dismiss()
            },
                           rightItem: .init(icon: .list) {
                print("설정")
            })
//            .navigationTitle("#모야모여모여랏")
            .navigationBarBackButtonHidden()
        }
        
    }
    // 메시지 전송 로직
    func sendMessage() {
        if !messageText.isEmpty || !selectedImages.isEmpty {
            messages.append(
                ChattingPresentModel(name: "ㅇㄹㄴ",
                            text: messageText,
                            imageNames: [],
                            isMine: true,
                            profile: nil)
            )
            messageText = ""
            selectedImages = []
            scrollViewID = UUID() // 새로운 메시지가 들어올 때마다 스크롤 ID 갱신
        }
    }
    
    // PHPicker를 표시하는 함수
    //    func showImagePicker() {
    //        let picker = PHPickerViewController(
    //            configuration: PHPickerConfiguration(photoLibrary: .shared())
    //        )
    //        picker.delegate = PHPickerHandler(selectedImages: $selectedImages)
    //        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    //    }
}
extension ChattingView {
    private func messageInputView() -> some View {
        HStack {
            // 입력 뷰
            HStack(alignment: .bottom) {
                // 이미지 선택 버튼
                ChattingPhotoPicker(selectedImages: $selectedImages) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundColor(Design.darkGray)
                }
                VStack(alignment: .leading) {
                    // 메시지 입력 필드
                    DynamicHeightTextField(text: $messageText)
                    if !selectedImages.isEmpty {
                        selectePhotoView(images: selectedImages)
                    }
                }
                // 전송버튼
                Button {
                    // 메세지 전송 로직
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(messageText.isEmpty && selectedImages.isEmpty
                                         ? Design.darkGray : Design.green)
                }
                .disabled(messageText.isEmpty && selectedImages.isEmpty)
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
    private func selectePhotoView(images: [UIImage]) -> some View {
        
        LazyHGrid(rows: [GridItem(.fixed(50))], spacing: 12, content: {
            // 이미지넣기
            ForEach(selectedImages, id: \.self) { image in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Button(action: {
                        print("클릭클릭")
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Design.black)
                            .background(
                                Circle().size(width: 20, height: 20)
                                    .foregroundColor(Design.white)
                            )
                            .offset(x: 22, y: -22)
                    })
                    
                }
                
            }
        })
        .frame(height: 55)
    }
}

// 채팅 메시지 뷰
struct ChatMessageView: View {
    var message: ChattingPresentModel
    
    var body: some View {
        
        if message.isMine {
            VStack(alignment: .trailing) {
                HStack(alignment: .bottom) {
                    Spacer()
                    Text("오후 8:10")
                        .font(Design.caption2)
                        .foregroundStyle(Design.darkGray)
                    VStack(alignment: .leading) {
                        if let text = message.text {
                            Text(text)
                                .font(Font.body)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12) // 둥근 모서리
                                        .fill(Design.white) // 배경색 설정
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.gray, lineWidth: 1) // 테두리 색과 두께 설정
                                )
                        }
//                        if let imageName = message.imageNames {
//                            ChattingImageView(imageNames: imageName)
//                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack(alignment: .top) {
                ProfileImageView(urlString: message.profile ?? "bird",
                                 size: 34)
                VStack(alignment: .leading) {
                    Text(message.name)
                        .font(Design.caption)
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            if let text = message.text {
                                Text(text)
                                    .font(Font.body)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12) // 둥근 모서리
                                            .fill(Design.white) // 배경색 설정
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Design.gray, lineWidth: 1) // 테두리 색과 두께 설정
                                    )
                            }
//                            if let imageName = message.imageNames {
//                                ChattingImageView(imageNames: imageName)
//                            }
                        }
                        Text("오후 8:10")
                            .font(Design.caption2)
                            .foregroundStyle(Design.darkGray)
                        Spacer()
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 5)
            
        }
        
    }
}

struct DynamicHeightTextField: View {
    @Binding var text: String
    private let placeholder = "메세지를 입력하세요"
    
    var body: some View {
        VStack {
            TextField("메세지를 입력하세요", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .background(Color.clear)
                .font(Design.body)
        }
    }
}

extension View {
    // 키보드 숨기기 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

#Preview {
    ChattingView()
}
