//
//  ChattingView.swift
//  Gathering
//
//  Created by 여성은 on 11/5/24.
//

import SwiftUI

import PhotosUI
import Combine

struct ChattingView: View {
    @State private var messageText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var messages: [ChatMessage] = [
        ChatMessage(name: "지수", text: "아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘아니! 어쩌구저쩌구 벌써 수료 ..!! 사진 좀 보내줘", images: [], isMine: false, profile: "bird"),
        ChatMessage(name: "아라", text: "그래그래 사진 보내줘~", images: [], isMine: false, profile: "bird2"),
        ChatMessage(name: "나야나", text: "아직 못보내~....", images: [], isMine: true, profile: "bird3"),
        ChatMessage(name: "성은", text: "^^>....", images: [], isMine: false, profile: "bird3")
        
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
            .navigationTitle("#모야모여모여랏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // 뒤로가기
                    }, label: {
                        Image("chevronLeft")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // 뒤로가기
                    }, label: {
                        Image("List")
                    })
                }
                
            }
        }
    }
    // 메시지 전송 로직
    func sendMessage() {
        if !messageText.isEmpty || !selectedImages.isEmpty {
            messages.append(
                ChatMessage(name: "ㅇㄹㄴ",
                            text: messageText,
                            images: selectedImages,
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
                Button {
                    //                            showImagePicker()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundColor(Design.darkGray)
                }
                
                VStack(alignment: .leading) {
                    // 메시지 입력 필드
                    DynamicHeightTextField(text: $messageText)
                    if !selectedImages.isEmpty {
                        selectePhotoView()
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
    private func selectePhotoView() -> some View {
        LazyHGrid(rows: [GridItem(.fixed(50))], spacing: 12, content: {
            // 이미지넣기
            Image(systemName: "star")
                .resizable()
                .frame(width: 44, height: 44)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 12)
                .overlay {
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
            Image(systemName: "star")
                .resizable()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 12)
                .overlay {
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
                            .offset(x: 20, y: -20)
                    })
                }
        })
        .frame(height: 55)
        .background(.red)
    }
}


// PHPicker 핸들러
//class PHPickerHandler: NSObject, PHPickerViewControllerDelegate {
//    @Binding var selectedImages: [UIImage]
//
//    init(selectedImages: Binding<[UIImage]>) {
//        _selectedImages = selectedImages
//    }
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//
//        for result in results {
//            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
//                    if let uiImage = image as? UIImage {
//                        DispatchQueue.main.async {
//                            self.selectedImages.append(uiImage)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

// 채팅 메시지 뷰
struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        
        if message.isMine {
            VStack(alignment: .trailing) {
                HStack(alignment: .bottom) {
                    Spacer()
                    Text("오후 8:10")
                        .font(Design.caption2)
                        .foregroundStyle(Design.darkGray)
                    Text(message.text)
                        .font(Font.body)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12) // 둥근 모서리
                                .fill(Color.white) // 배경색 설정
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1) // 테두리 색과 두께 설정
                        )
                }
                
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack(alignment: .top) {
                ProfileImageView(imageName: message.profile ?? "bird",
                                 size: 34)
                VStack(alignment: .leading) {
                    Text(message.name)
                        .font(Design.caption)
                    HStack(alignment: .bottom) {
                        Text(message.text)
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

#Preview {
    ChattingView()
}
