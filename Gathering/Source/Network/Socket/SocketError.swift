//
//  SocketError.swift
//  Gathering
//
//  Created by 김성민 on 12/4/24.
//

import Foundation

enum SocketError: Error {
    case invalidURL         // 웹 소켓을 연결할 URL이 잘못된 경우
    case invalidText        // 웹 소켓으로 전송할 텍스트가 잘못된 경우
    case invalidData        // 웹 소켓으로 전송할 데이터(이미지)가 잘못된 경우
    case messageSendFailed  // 메세지 전송이 실패한 경우
    case unknownError
}
