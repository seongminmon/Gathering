//
//  UserDefaultsManager.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

enum UserDefaultsManager {
    
    private enum Key: String {
        case accessToken
        case refreshToken
        case userID
        case workspaceID
    }
    
    @UserDefault(key: Key.accessToken.rawValue, defaultValue: "")
    static var accessToken
    
    @UserDefault(key: Key.refreshToken.rawValue, defaultValue: "")
    static var refreshToken
    
    @UserDefault(key: Key.userID.rawValue, defaultValue: "")
    static var userID
    
    @UserDefault(key: Key.workspaceID.rawValue, defaultValue: "")
    static var workspaceID
    
    static var isLoggedIn: Bool {
        return !accessToken.isEmpty &&
        !refreshToken.isEmpty &&
        !userID.isEmpty
    }
    
    static func refresh(_ accessToken: String) {
        UserDefaultsManager.accessToken = accessToken
    }
    
    static func signIn(_ accessToken: String, _ refreshToken: String, _ id: String) {
        UserDefaultsManager.accessToken = accessToken
        UserDefaultsManager.refreshToken = refreshToken
        UserDefaultsManager.userID = id
    }
    
    static func saveWorkspaceID(_ workspaceID: String) {
        UserDefaultsManager.workspaceID = workspaceID
    }
    
    static func removeAll() {
        UserDefaultsManager.accessToken = ""
        UserDefaultsManager.refreshToken = ""
        UserDefaultsManager.userID = ""
        UserDefaultsManager.workspaceID = ""
    }
}
