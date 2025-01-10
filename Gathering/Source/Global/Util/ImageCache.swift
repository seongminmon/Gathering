//
//  ImageCache.swift
//  Gathering
//
//  Created by 김성민 on 11/20/24.
//

import UIKit

class ImageCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB 제한
        return cache
    }()
}
