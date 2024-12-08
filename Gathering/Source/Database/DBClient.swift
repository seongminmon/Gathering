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
    
    //    var create: (Object) throws -> Void
    var update: @Sendable (Object) throws -> Void
    var delete: (Object) throws -> Void
    
    var createChannelChatting: @Sendable (String, ChannelChattingDBModel) throws -> Void
    //    var addChannelMember: (String, MemberDBModel) throws -> Void
    var createDMChatting: @Sendable (String, DMChattingDBModel) throws -> Void
    //    var addDMMember: (String, MemberDBModel) throws -> Void
    
    // Channel 관련
    var updateChannel: @Sendable (ChannelDBModel, String, [MemberDBModel]) throws -> Void
    var fetchChannel: @Sendable (String) throws -> ChannelDBModel?
    var fetchAllChannel: @Sendable () throws -> [ChannelDBModel]
    
    // DM 관련
    var updateDMRoom: @Sendable (DMRoomDBModel, [MemberDBModel]) throws -> Void
    var fetchDMRoom: @Sendable (String) throws -> DMRoomDBModel?
    var fetchAllDMRoom: @Sendable () throws -> [DMRoomDBModel]
    
    // 멤버 관련
    var fetchMember: @Sendable (String) throws -> MemberDBModel?
    
    var removeAll: @Sendable () throws -> Void
}

extension DBClient: DependencyKey {
    static let liveValue = DBClient(
        // MARK: - 기본 CRUD
        printRealm: {
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "realm 경로 없음")
        },
        //        create: { object in
        //            let realm = try Realm()
        //            try realm.write {
        //                realm.add(object)
        //            }
        //        },
        // MARK: - 일단 전부 update로 해보기
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
            // `object.user`가 중복되는지 확인하고 처리
            if let user = object.user {
                if let existingUser = realm.object(
                    ofType: MemberDBModel.self,
                    forPrimaryKey: user.userID
                ) {
                    // 이미 저장된 `MemberDBModel` 객체를 사용
                    try realm.write {
                        existingUser.profileImage = user.profileImage
                        existingUser.nickname = user.nickname
                    }
                    object.user = existingUser
                } else {
                    // 새로운 유저를 저장
                    try realm.write {
                        realm.add(user)
                    }
                }
            }
            // 채팅 추가
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
            // `object.user`가 중복되는지 확인하고 처리
            if let user = object.user {
                if let existingUser = realm.object(
                    ofType: MemberDBModel.self,
                    forPrimaryKey: user.userID
                ) {
                    // 이미 저장된 `MemberDBModel` 객체를 사용
                    try realm.write {
                        existingUser.profileImage = user.profileImage
                        existingUser.nickname = user.nickname
                    }
                    object.user = existingUser
                } else {
                    // 새로운 유저를 저장
                    try realm.write {
                        realm.add(user)
                    }
                }
            }
            // 채팅 추가
            try realm.write {
                dmRoom.chattings.append(object)
            }
        },
        updateChannel: { channel, channelName, members in
            let realm = try Realm()
            try realm.write {
                channel.channelName = channelName
                for newMember in members {
                    if let existingMember = realm.object(
                        ofType: MemberDBModel.self,
                        forPrimaryKey: newMember.userID
                    ) {
                        // 이미 존재하면 필요한 필드만 업데이트
                        existingMember.nickname = newMember.nickname
                        existingMember.profileImage = newMember.profileImage
                    } else {
                        // 존재하지 않으면 추가
                        realm.add(newMember)
                    }
                    
                    // 중복 방지 후 채널 멤버 리스트에 추가
                    if !channel.members.contains(where: { $0.userID == newMember.userID }) {
                        channel.members.append(newMember)
                    }
                }
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
        updateDMRoom: { dmRoom, members in
            let realm = try Realm()
            
            try realm.write {
                for newMember in members {
                    if let existingMember = realm.object(
                        ofType: MemberDBModel.self,
                        forPrimaryKey: newMember.userID
                    ) {
                        // 이미 존재하면 필요한 필드만 업데이트
                        existingMember.nickname = newMember.nickname
                        existingMember.profileImage = newMember.profileImage
                    } else {
                        // 존재하지 않으면 추가
                        realm.add(newMember)
                    }
                    
                    // 중복 방지 후 채널 멤버 리스트에 추가
                    if !dmRoom.members.contains(where: { $0.userID == newMember.userID }) {
                        dmRoom.members.append(newMember)
                    }
                }
            }
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
        }, removeAll: {
            print("DB 전체 삭제")
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        }
    )
}

extension DependencyValues {
    var dbClient: DBClient {
        get { self[DBClient.self] }
        set { self[DBClient.self] = newValue }
    }
}
