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
    //    var delete: (Object) throws -> Void
    
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
        //        delete: { object in
        //            let realm = try Realm()
        //            try realm.write {
        //                realm.delete(object)
        //            }
        //        },
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
                if let existingUser = realm.object(ofType: MemberDBModel.self, forPrimaryKey: user.userID) {
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
/*
 import SwiftUI

 import ComposableArchitecture

 @Reducer
 struct DMChattingFeature {
     
     @Dependency(\.dmsClient) var dmsClient
     @Dependency(\.dbClient) var dbClient
     @Dependency(\.dbActor) var dbActor
     @Dependency(\.userClient) var userClient
     
     @ObservableState
     struct State {
 //        var opponentID: String
 //        var workspaceID: String
         
         var dmsRoomResponse: DMsRoom
         var message: [ChattingPresentModel] = []
         
         var messageText = ""
         var selectedImages: [UIImage]? = []
         var scrollViewID = UUID()
         var keyboardHeight: CGFloat = 0
         
         var messageButtonValid = false
     }
     
     enum Action: BindableAction {
         case binding(BindingAction<State>)
         
         case task
         case sendButtonTap
         case imageDeleteButtonTap(UIImage)
         case profileButtonTap(Member)
         
         case fetchDBChatting(DMsResponse)
         case sendDmMessage
         case savedDBChattingResponse([ChattingPresentModel])
         case sendMessageError(Error)
     }
     
     var body: some ReducerOf<Self> {
         BindingReducer()
         Reduce { state, action in
             switch action {
             case .profileButtonTap(let user):
                 // homeview와 dmView에서 path로 처리
                 return .none
                 
             case .binding(\.messageText):
                 state.messageButtonValid = !state.messageText.isEmpty
                 || !(state.selectedImages?.isEmpty ?? true)
                 return .none
                 
             case .binding(\.selectedImages):
                 state.messageButtonValid = !(state.selectedImages?.isEmpty ?? true)
                 || !(state.selectedImages?.isEmpty ?? true)
                 return .none
                 
             case .task:
                 return .run { [state = state] send in
                     // DMRoom 확인, 저장/업데이트
                     do {
                         let opponentInfo = state.dmsRoomResponse.user.toDBModel()
                         let myInfo = try await userClient.fetchMyProfile().toDBModel()
                         let members: [MemberDBModel] = [opponentInfo, myInfo]
                         
                         if let dbDMsRoom = try await dbActor.fetchDMRoom(state.dmsRoomResponse.id) {
                             do {
                                 try await dbActor.updateDMRoom(dbDMsRoom, members)
                                 print("DB DMRoom 업데이트 성공")
                             } catch {
                                 print("DB DMRoom 업데이트 실패")
                             }
                         } else {
                             print("DB에 DMsRoom없음")
                             do {
                                 let dmsRoom = state.dmsRoomResponse.toDBModel(members)
                                 try await dbActor.update(dmsRoom)
                                 print("DB DMsRoom 저장 성공")
                             } catch {
                                 print("DB DMsRoom 저장 실패")
                             }
                             
                         }
                     } catch {
                         print("DB DmRoom 저장/업데이트 실패")
                     }
                     
 //                    // 채팅 추가하기
                     do {
                         // 채널 불러오기
                         guard let dbDMsRoom = try await dbActor.fetchDMRoom(
                             state.dmsRoomResponse.id
                         ) else { return }
                         
                         // 디비에서 기존 채팅 불러오기
                         let dbDMsChats = Array(dbDMsRoom.chattings
                             .sorted(byKeyPath: "createdAt", ascending: true))
                         print("기존채팅", dbDMsChats)
                         
                         // 마지막 날짜 이후 채팅 불러오기
                         let newDMsChats = try await dmsClient.fetchDMChatHistory(
                             UserDefaultsManager.workspaceID,
                             dbDMsRoom.roomID,
                             dbDMsChats.last?.createdAt ?? ""
                         )
                         print("신규채팅", newDMsChats)
                         
 //                        for chat in newDMsChats {
 //                            do {
 //                                try dbClient.createDMChatting(
 //                                    dbDMsRoom.roomID,
 //                                    chat.toDBModel(chat.user.toDBModel())
 //                                )
 //                                print("DB 신규채팅 추가 성공")
 //                            } catch {
 //                                print("DB 신규채팅 추가 실패")
 //                            }
 //
 //                            // 비동기 작업 처리
 //                            for file in chat.files {
 //                                await ImageFileManager.shared.saveImageFile(filename: file)
 //                            }
 //                        }
                         
                         // 불러온 채팅 디비에 저장하기
                         await withTaskGroup(of: Void.self) { group in
                             for chat in newDMsChats {
                                 // 채팅 저장 작업
                                 group.addTask {
                                     do {
                                         try await dbActor.createDMChatting(
                                             dbDMsRoom.roomID,
                                             chat.toDBModel(chat.user.toDBModel())
                                         )
                                         print("DB 신규채팅 추가 성공")
                                     } catch {
                                         print("DB 신규채팅 추가 실패")
                                     }
                                 }
                                 
                                 // 파일 저장 작업
                                 for file in chat.files {
                                     group.addTask {
                                         await ImageFileManager.shared
                                             .saveImageFile(filename: file)
                                     }
                                 }
                             }
                         }
                         
                         guard let updatedDbDmsRoom = try await dbActor
                             .fetchDMRoom(dbDMsRoom.roomID) else { return }
                         
                         let updatedChats = Array(updatedDbDmsRoom.chattings).map {
                             $0.toPresentModel()
                         }
                         await send(.savedDBChattingResponse(updatedChats))
                         
                     } catch {
                         print("채팅 불러오기, 저장 실패")
                     }
                 }

             case .sendButtonTap:
                 return .run { [state = state] send in
                     do {
                         guard let images = state.selectedImages, !images.isEmpty else {
                             let result = try await dmsClient.sendDMMessage(
                                 UserDefaultsManager.workspaceID,
                                 state.dmsRoomResponse.id,
                                 DMRequest(content: state.messageText, files: [])
                             )
                             do {
                                 let member = MemberDBModel()
                                 try dbClient.update(result.toDBModel(member))
                                 print("sendedDM 저장성공")
 //                                await send(.saveSendedDM(result))
                             } catch {
                                 print("Realm 추가 실패")
                             }
                             return
                         }
                         let jpegData = images.map({ value in
                             value.jpegData(compressionQuality: 0.5)!
                         })
                         
                         let result = try await dmsClient.sendDMMessage(
                             UserDefaultsManager.workspaceID,
                             state.dmsRoomResponse.id,
                             DMRequest(
                                 content: state.messageText,
                                 files: jpegData
                             )
                         )
                         do {
                             // MARK: - 멤버 잘 찾아서 넣기
                             let member = MemberDBModel()
                             try dbClient.update(result.toDBModel(member))
                             print("sendedDM 저장성공")
 //                            await send(.saveSendedDM(result))
                         } catch {
                             print("Realm 추가 실패")
                         }
                     } catch {
                         print("멀티파트 실패 ㅠㅠ ")
                         await send(.sendMessageError(error))
                     }
                 }
                 
             case .imageDeleteButtonTap(let image):
                 guard let index = state.selectedImages?.firstIndex(of: image) else {
                     return .none
                 }
                 let newImages = state.selectedImages?.remove(at: index)
                 print(state.selectedImages)
                 return .none
                 
             case .sendDmMessage:
                 state.messageText = ""
                 state.selectedImages = []
                 state.messageButtonValid = false
                 return .none

             case .savedDBChattingResponse(let updatedDBChats):
                 state.message = updatedDBChats
                 return .none
                 
             case .sendMessageError(let error):
                 Notification.postToast(title: "메세지 전송 실패")
                 print(error)
                 return .none
                 
             default:
                 return .none
             }
         }
     }
     
     private func fetchNewDMsChatting(
         workspaceID: String,
         roomID: String,
         cursorDate: String?
     ) async throws -> [DMsResponse] {
         async let newChats = dmsClient.fetchDMChatHistory(
             workspaceID,
             roomID,
             cursorDate ?? "")
         return try await newChats
     }
 }
 */
