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
        ChatMessage(name: "지수", text: "djfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuiodjfshfeuio", images: [], isMine: false),
        ChatMessage(name: "아라", text: "djfshfeuio", images: [], isMine: false),
        ChatMessage(name: "성은", text: "djfshfeuio", images: [], isMine: false)
        
    ]
    @State private var scrollViewID = UUID()
    @State private var keyboardHeight: CGFloat = 0 // 키보드 높이 상태 저장
    
    private var keyboardSubscriber: AnyCancellable?
    
    //    init() {
    //        // 키보드 노티피케이션 구독
    //        keyboardSubscriber = NotificationCenter.default
    //        .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
    //            .compactMap { notification -> CGFloat? in
    //                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
    //    as? CGRect else { return nil }
    //                return frame.height
    //            }
    //            .sink { [weak self] height in
    //                withAnimation {
    //                    self.keyboardHeight = self.height == UIScreen.main.bounds.height ? 0 : height
    //                }
    //            }
    //    }
    
    var body: some View {
        VStack {
            // 채팅 메시지 리스트
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            ChatMessageView(message: message)
                        }
                    }
                    .padding(.horizontal, 20)
                    .id(scrollViewID)
                }
                .background{
                    Color.yellow
                }
                .onChange(of: messages.count) { _ in
                    // 메시지 추가 시 자동 스크롤
                    withAnimation {
                        proxy.scrollTo(scrollViewID, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // 입력 뷰
            HStack(alignment: .bottom) {
                // 이미지 선택 버튼
                Button {
                    showImagePicker()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                
                // 선택한 이미지 프리뷰
                //                ScrollView(.horizontal, showsIndicators: false) {
                //                    HStack {
                //                        ForEach(selectedImages, id: \.self) { image in
                //                            Image(uiImage: image)
                //                                .resizable()
                //                                .scaledToFill()
                //                                .frame(width: 40, height: 40)
                //                                .cornerRadius(8)
                //                                .overlay(
                //                                    Button(action: {
                //                                        // 선택한 이미지 제거 로직
                //                                        if let index = selectedImages.firstIndex(of: image) {
                //                                            selectedImages.remove(at: index)
                //                                        }
                //                                    }) {
                //                                        Image(systemName: "xmark.circle.fill")
                //                                            .foregroundColor(.white)
                //                                            .background(Color.black.opacity(0.5))
                //                                            .clipShape(Circle())
                //                                    }
                //                                    .offset(x: 10, y: -10)
                //                                )
                //                        }
                //                    }
                //                }
                
                // 메시지 입력 필드
                TextEditor(text: $messageText)
                    .frame(maxHeight: 100)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
                    )
                
                // 전송버튼
                Button {
                    // 메세지 전송 로직
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                        .foregroundColor(messageText.isEmpty && selectedImages.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty && selectedImages.isEmpty)
            }
            .padding()
            .background(Color.white) // 입력 창 배경색
            .offset(y: -keyboardHeight) // 키보드가 올라올 때 입력창도 같이 올라가게 함
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
        }
        .onTapGesture {
            // 화면을 탭할 때 키보드 내리기
            hideKeyboard()
        }
        .onDisappear {
            // 뷰가 사라질 때 키보드 노티피케이션 구독 해제
            keyboardSubscriber?.cancel()
        }
    }
    
    // 메시지 전송 로직
    func sendMessage() {
        if !messageText.isEmpty || !selectedImages.isEmpty {
            messages.append(
                ChatMessage(name: "ㅇㄹㄴ", 
                            text: messageText,
                            images: selectedImages,
                            isMine: true)
            )
            messageText = ""
            selectedImages = []
            scrollViewID = UUID() // 새로운 메시지가 들어올 때마다 스크롤 ID 갱신
        }
    }
    
    // PHPicker를 표시하는 함수
    func showImagePicker() {
        let picker = PHPickerViewController(configuration: PHPickerConfiguration(photoLibrary: .shared()))
        picker.delegate = PHPickerHandler(selectedImages: $selectedImages)
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
}

// 키보드 숨기기 메서드
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// 메시지 모델 정의
struct ChatMessage: Identifiable {
    var id = UUID()
    let name: String
    let text: String
    let images: [UIImage]
    let date = Date()
    let isMine: Bool
}

// PHPicker 핸들러
class PHPickerHandler: NSObject, PHPickerViewControllerDelegate {
    @Binding var selectedImages: [UIImage]
    
    init(selectedImages: Binding<[UIImage]>) {
        _selectedImages = selectedImages
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedImages.append(uiImage)
                        }
                    }
                }
            }
        }
    }
}

// 채팅 메시지 뷰
struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading) {
                Text(message.name)
                    .font(Font.caption)
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
    }
}



//struct ChattingView: View {
//    var body: some View {
//        VStack {
//            VStack {
//
//
//                ScrollViewReader { proxy in
//                    ScrollView {
////                        ForEach(messagesManager.messages, id: \.id) { message in
////                            MessageBubble(message: message)
////                        }
//                    }
//                    .padding(.top, 10)
//                    .background(.white)
//                    .cornerRadius(30, corners: [.topLeft, .topRight])
////                    .onChange(of: messagesManager.lastMessageId) { id in
////                        // When the lastMessageId changes, scroll to the bottom of the conversation
////                        withAnimation {
////                            proxy.scrollTo(id, anchor: .bottom)
////                        }
////                    }
//                }
//            }
//            .background(Color("Peach"))
//
//            MessageFieldView()
//        }
//    }
//
//}
//
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners) )
//    }
//}
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect,
//                                byRoundingCorners: corners,
//                                cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}

#Preview {
    ChattingView()
}
