//
//  ImageClient.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import UIKit

import ComposableArchitecture

//class ImageCache {
//    static let shared: NSCache<NSURL, UIImage> = {
//        let cache = NSCache<NSURL, UIImage>()
//        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB 제한
//        return cache
//    }()
//}
//
//struct ImageClient {
//    var fetchImage: (String) async throws -> UIImage
//}
//
//extension ImageClient: DependencyKey {
//    static let liveValue = ImageClient(
//        fetchImage: { path in
//            return try await NetworkManager.shared.request(
//                api: ImageRouter.fetchImage(path: path)
//            )
//        }
//    )
//}
//
//extension DependencyValues {
//    var imageClient: ImageClient {
//        get { self[ImageClient.self] }
//        set { self[ImageClient.self] = newValue }
//    }
//}
