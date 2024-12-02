//
//  DBClient.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

// TODO: - 파일 매니저 이용하기

// 내 프로필 이미지
// 다른 유저 프로필 이미지
// 워크스페이스 이미지
// (채널 이미지)
// 채널 채팅 이미지
// DM 채팅 이미지

import Foundation

import Dependencies
import RealmSwift

struct DBClient {
    var printRealm: () -> Void
    
    var create: @Sendable (Object) throws -> Void
    var update: @Sendable (Object) throws -> Void
    var delete: @Sendable (Object) throws -> Void
    
    // Channel Chatting 관련
//    var fetchChannelChat: @Sendable (String) throws -> ChannelChattingRealmModel?
//    var fetchChannelChats: @Sendable (String) throws -> [ChannelChattingDBModel]
//    var fetchAllChannelChats: @Sendable () throws -> [ChannelChattingRealmModel]
    
    // DM 관련
//    var fetchDMChat: @Sendable (String) throws -> DMChattingDBModel?
//    var fetchDMChats: @Sendable (String) throws -> [DMChattingDBModel]
//    var fetchAllDMChats: @Sendable () throws -> [DMChattingDBModel]
}

extension DBClient: DependencyKey {
    static let liveValue = DBClient(
        // MARK: - 기본 CRUD
        printRealm: {
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "realm 경로 없음")
        },
        create: { object in
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        },
        update: { object in
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: .modified)
            }
        },
        delete: { object in
            let realm = try Realm()
            try realm.write {
                realm.delete(object)
            }
        }
        
        // MARK: - Channel Chatting 관련
//        fetchChannelChat: { chatID in
//            let realm = try Realm()
//            return realm.object(ofType: ChannelChattingRealmModel.self, forPrimaryKey: chatID)
//        },
//        fetchChannelChats: { channelID in
//            let realm = try Realm()
//            let chats = realm.objects(ChannelChattingDBModel.self)
//                .filter { $0.channelID == channelID }
//                .sorted { $0.createdAt < $1.createdAt }
//            return Array(chats)
//        },
//        fetchAllChannelChats: {
//            let realm = try Realm()
//            return Array(realm.objects(ChannelChattingRealmModel.self))
//        },
        
        // MARK: - DM 관련
//        fetchDMChat: { dmID in
//            let realm = try Realm()
//            return realm.object(ofType: DMChattingDBModel.self, forPrimaryKey: dmID)
//        },
//        fetchDMChats: { roomID in
//            let realm = try Realm()
//            let chats = realm.objects(DMChattingDBModel.self)
//                .filter { $0.roomID == roomID }
//                .sorted { $0.createdAt < $1.createdAt }
//            return Array(chats)
//        }
//        fetchAllDMChats: {
//            let realm = try Realm()
//            return Array(realm.objects(DMChattingDBModel.self))
//        }
    )
}

extension DependencyValues {
    var dbClient: DBClient {
        get { self[DBClient.self] }
        set { self[DBClient.self] = newValue }
    }
}
