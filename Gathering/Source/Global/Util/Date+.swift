//
//  Date+.swift
//  Gathering
//
//  Created by 김성민 on 11/21/24.
//

import Foundation

// API에서 받은 createdAt은 ISO8601 형태의 String (UTC)
// 뷰에 표시할 땐 Date 타입으로 변환 후 다시 String 타입으로 변환이 필요

enum DateFormat: String {
//    case createdAt = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // ISO 8601 형식
    case todayChat = "hh:mm a"
    case pastChat = "MM/dd h:mm a"
}

extension Date {
    static let dateFormatter = DateFormatter()
    static let isoDateFormatter = ISO8601DateFormatter()
    
    func toString(_ dateFormat: DateFormat) -> String {
        Self.dateFormatter.dateFormat = dateFormat.rawValue
        // View에 표시할 땐 현재 기기의 timeZone으로 설정하기 위해 기본값 사용하기
        //Self.dateFormatter.timeZone = .gmt
        return Self.dateFormatter.string(from: self)
    }
}

extension String {
    /// ISO8601 형식의 createdAt String을 Date로 변환
    func createdAtToDate() -> Date? {
        Date.isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return Date.isoDateFormatter.date(from: self)
    }
}
