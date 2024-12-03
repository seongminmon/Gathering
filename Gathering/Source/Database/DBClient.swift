//
//  DBClient.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

// TODO: - 파일 매니저 이용하기

// 내 프로필 이미지
// 다른 유저 프로필 이미지
// 채널 채팅 이미지
// DM 채팅 이미지

import Foundation

import Dependencies
import RealmSwift

struct DBClient {
    var printRealm: () -> Void
    
    // TODO: - 쓰레드 문제 생기면 @Sendable 붙이기
    // var create: @Sendable (Object) throws -> Void
    var create: (Object) throws -> Void
    var update: (Object) throws -> Void
    var delete: (Object) throws -> Void
    
    var createChannelChatting: (String, ChannelChattingDBModel) throws -> Void
//    var addChannelMember: (String, MemberDBModel) throws -> Void
    var createDMChatting: (String, DMChattingDBModel) throws -> Void
//    var addDMMember: (String, MemberDBModel) throws -> Void
    
    // Channel 관련
    var fetchChannel: (String) throws -> ChannelDBModel?
    var fetchAllChannel: () throws -> [ChannelDBModel]
    
    // DM 관련
    var fetchDMRoom: (String) throws -> DMRoomDBModel?
    var fetchAllDMRoom: () throws -> [DMRoomDBModel]
    
    // 멤버 관련
    var fetchMember: (String) throws -> MemberDBModel?
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
        },
        createChannelChatting: { channelID, object in
            let realm = try Realm()
            guard let channel = realm.object(
                ofType: ChannelDBModel.self,
                forPrimaryKey: channelID
            ) else {
                print("채널을 찾을 수 없습니다.")
                return
            }
            try realm.write {
                channel.chattings.append(object)
            }
        },
        createDMChatting: { roomID, object in
            let realm = try Realm()
            guard let dmRoom = realm.object(
                ofType: DMRoomDBModel.self,
                forPrimaryKey: roomID
            ) else {
                print("DM룸을 찾을 수 없습니다.")
                return
            }
            try realm.write {
                dmRoom.chattings.append(object)
            }
        },
        fetchChannel: { channelID in
            let realm = try Realm()
            return realm.object(ofType: ChannelDBModel.self, forPrimaryKey: channelID)
        },
        fetchAllChannel: {
            let realm = try Realm()
            return Array(realm.objects(ChannelDBModel.self))
        },
        fetchDMRoom: { roomID in
            let realm = try Realm()
            return realm.object(ofType: DMRoomDBModel.self, forPrimaryKey: roomID)
        },
        fetchAllDMRoom: {
            let realm = try Realm()
            return Array(realm.objects(DMRoomDBModel.self))
        },
        fetchMember: { userID in
            let realm = try Realm()
            return realm.object(ofType: MemberDBModel.self, forPrimaryKey: userID)
        }
    )
}

extension DependencyValues {
    var dbClient: DBClient {
        get { self[DBClient.self] }
        set { self[DBClient.self] = newValue }
    }
}
