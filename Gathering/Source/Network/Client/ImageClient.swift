//
//  ImageClient.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import UIKit

import ComposableArchitecture

struct ImageClient {
    var fetchImage: (String) async throws -> UIImage
}

extension ImageClient: DependencyKey {
    static let liveValue = ImageClient(
        fetchImage: { path in
            return try await NetworkManager.shared.requestImage(.fetchImage(path: path))
        }
    )
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
