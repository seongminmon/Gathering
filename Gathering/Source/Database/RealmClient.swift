//
//  RealmClient.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import Dependencies
import RealmSwift

struct RealmClient {
    var printRealm: () -> Void
    var create: @Sendable (Object) throws -> Void
    var update: @Sendable (Object) throws -> Void
    var delete: @Sendable (Object) throws -> Void
    
    // Channel Chatting 관련
    var fetchChannelChat: @Sendable (String) throws -> ChannelChattingRealmModel?
    var fetchChannelChats: @Sendable (String) throws -> [ChannelChattingRealmModel]
    var fetchAllChannelChats: @Sendable () throws -> [ChannelChattingRealmModel]
    
    // DM 관련
    var fetchDMChat: @Sendable (String) throws -> DMChattingRealmModel?
    var fetchDMChats: @Sendable (String) throws -> [DMChattingRealmModel]
    var fetchAllDMChats: @Sendable () throws -> [DMChattingRealmModel]
}

extension RealmClient: DependencyKey {
    static let liveValue = RealmClient(
        // MARK: - 기본 CRUD
        printRealm: {
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "realm 경로 없음")
        }, create: { object in
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
        },
        
        // MARK: - Channel Chatting 관련
        fetchChannelChat: { chatID in
            let realm = try Realm()
            return realm.object(ofType: ChannelChattingRealmModel.self, forPrimaryKey: chatID)
        },
        fetchChannelChats: { channelID in
            let realm = try Realm()
            let chats = realm.objects(ChannelChattingRealmModel.self)
                .filter("channelID == %@", channelID)
                .sorted(byKeyPath: "savedDate", ascending: true)
            return Array(chats)
        },
        fetchAllChannelChats: {
            let realm = try Realm()
            return Array(realm.objects(ChannelChattingRealmModel.self))
        },
        
        // MARK: - DM 관련
        fetchDMChat: { dmID in
            let realm = try Realm()
            return realm.object(ofType: DMChattingRealmModel.self, forPrimaryKey: dmID)
        },
        fetchDMChats: { roomID in
            let realm = try Realm()
            let chats = realm.objects(DMChattingRealmModel.self)
                .filter("roomID == %@", roomID)
                .sorted(byKeyPath: "savedDate", ascending: true)
            return Array(chats)
        },
        fetchAllDMChats: {
            let realm = try Realm()
            return Array(realm.objects(DMChattingRealmModel.self))
        }
    )
}

extension DependencyValues {
    var realmClient: RealmClient {
        get { self[RealmClient.self] }
        set { self[RealmClient.self] = newValue }
    }
}
