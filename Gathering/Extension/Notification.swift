//
//  Notification.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import Foundation

extension Notification.Name {
    static let showToast = Notification.Name("ShowToast")
}

extension Notification {
    enum UserInfoKey {
        static let toast = "toast"
    }

    var toast: Toast? {
        return userInfo?[UserInfoKey.toast] as? Toast
    }
}
