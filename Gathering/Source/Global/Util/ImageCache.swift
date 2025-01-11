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
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB 제한
        return cache
    }()
}
