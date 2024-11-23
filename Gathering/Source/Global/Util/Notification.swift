//
//  Notification.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import Foundation

extension Notification.Name {
    static let showToast = Notification.Name("ShowToast")
    static let changeRoot = Notification.Name("ChangeRoot")
}

extension Notification {
    enum UserInfoKey {
        static let toast = "toast"
        static let changeRoot = "ChangeRoot"
    }

    var toast: Toast? {
        return userInfo?[UserInfoKey.toast] as? Toast
    }
    
    static func postToast(title: String) {
        let toast = Toast(title: title)
        NotificationCenter.default.post(
            name: .showToast,
            object: nil,
            userInfo: [UserInfoKey.toast: toast]
        )
    }
    
    static func changeRoot(_ route: AppFeature.LoginState) {
            NotificationCenter.default.post(
                name: .changeRoot,
                object: nil,
                userInfo: [UserInfoKey.changeRoot: route]
            )
        }
}
