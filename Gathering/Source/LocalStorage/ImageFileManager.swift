//
//  ImageFileManager.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import UIKit

final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() {}
    
    private let maxCacheSize = 500 * 1024 * 1024 // 500MB 제한
    
    // 도큐먼트 폴더 위치
    private let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first
    
    private var staticDirectory: URL? {
        return documentDirectory?.appendingPathComponent("static")
    }
    
    private var profilesDirectory: URL? {
        return staticDirectory?.appendingPathComponent("profiles")
    }
    
    private var channelChatsDirectory: URL? {
        return staticDirectory?.appendingPathComponent("channelChats")
    }
    
    private var dmChatsDirectory: URL? {
        return staticDirectory?.appendingPathComponent("dmChats")
    }
    
    /// 이미지 폴더 및 하위 폴더 생성
    func createImageDirectory() {
        guard let staticDirectory else {
            print("static 폴더 경로를 생성할 수 없음")
            return
        }
        
        if FileManager.default.fileExists(atPath: staticDirectory.path) {
            print("static 폴더가 이미 존재합니다.")
        } else {
            do {
                try FileManager.default.createDirectory(
                    at: staticDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("static 폴더 생성 완료")
            } catch {
                print("static 폴더 생성 실패:", error)
            }
        }
        
        // profiles, channelChats, dmChats 디렉토리 생성
        createSubDirectory(at: profilesDirectory)
        createSubDirectory(at: channelChatsDirectory)
        createSubDirectory(at: dmChatsDirectory)
    }
    
    /// 하위 디렉토리 생성 함수
    private func createSubDirectory(at directory: URL?) {
        guard let directory = directory else { return }
        guard !FileManager.default.fileExists(atPath: directory.path) else {
            print("\(directory.lastPathComponent) 폴더가 이미 존재합니다.")
            return
        }
        
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("\(directory.lastPathComponent) 폴더 생성 완료")
        } catch {
            print("\(directory.lastPathComponent) 폴더 생성 실패:", error)
        }
    }
    
    /// 이미지로 저장
    func saveImageFile(filename: String, image: UIImage) {
        guard !filename.isEmpty, let documentDirectory else { return }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        do {
            try data.write(to: fileURL)
            updateAccessDate(for: fileURL)
            print("이미지 파일 저장 성공")
        } catch {
            print("이미지 파일 저장 실패", error)
        }
        handleCacheLimit()
    }
    
    /// 파일 이름으로 저장 (내부에서 통신)
    func saveImageFile(filename: String) async {
        guard !filename.isEmpty, let documentDirectory else { return }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        do {
            let image = try await NetworkManager.shared.requestImage(
                ImageRouter.fetchImage(path: filename)
            )
            guard let data = image.jpegData(compressionQuality: 0.5) else { return }
            do {
                try data.write(to: fileURL)
                updateAccessDate(for: fileURL)
                print("이미지 파일 저장 성공")
            } catch {
                print("이미지 파일 저장 실패", error)
            }
        } catch {
            print("이미지 파일 통신 실패")
        }
        handleCacheLimit()
    }
    
    func loadImageFile(filename: String) -> UIImage? {
        guard !filename.isEmpty, let documentDirectory else { return nil }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            updateAccessDate(for: fileURL)
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return nil
        }
    }
    
    func deleteImageFile(filename: String) {
        guard !filename.isEmpty, let documentDirectory else { return }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("이미지 파일 삭제 성공")
            } catch {
                print("이미지 파일 삭제 실패", error)
            }
        } else {
            print("이미지 파일 없음")
        }
    }
    
    /// 이미지 폴더 내부 파일 모두 삭제
    func deleteAllImages() {
        guard let profilesDirectory, let channelChatsDirectory, let dmChatsDirectory else { return }
        [profilesDirectory, channelChatsDirectory, dmChatsDirectory].forEach { directory in
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                for fileURL in fileURLs {
                    try FileManager.default.removeItem(at: fileURL)
                }
                print("이미지 폴더 내부 파일 삭제 완료")
            } catch {
                print("이미지 폴더 내부 파일 삭제 실패:", error)
            }
        }
    }
}

extension ImageFileManager {
    
    /// 파일 접근 시간 정보 갱신
    private func updateAccessDate(for fileURL: URL) {
        do {
            try FileManager.default.setAttributes(
                [.modificationDate: Date()],
                ofItemAtPath: fileURL.path
            )
        } catch {
            print("파일 접근 시간 갱신 실패:", error)
        }
    }
    
    private func calculateDirectorySize() -> Int {
        guard let staticDirectory else { return 0 }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: staticDirectory,
                includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
                options: .skipsHiddenFiles
            )
            return fileURLs.reduce(0) { total, fileURL in
                return total + fileURL.fileSize()
            }
        } catch {
            print("디렉토리 크기 계산 실패:", error)
            return 0
        }
    }
    
    /// 용량이 차면 LRU 방식으로 파일 삭제
    private func handleCacheLimit() {
        guard let staticDirectory else { return }
        var directorySize = calculateDirectorySize()
        guard directorySize > maxCacheSize else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: staticDirectory,
                includingPropertiesForKeys: [.contentAccessDateKey, .totalFileAllocatedSizeKey],
                options: .skipsHiddenFiles
            )
            
            // 파일 접근 시간 오래된 순으로 정렬
            let sortedFiles = fileURLs.sorted { $0.accessDate() < $1.accessDate() }
            
            // 용량 제한에 맞을 때까지 오래된 파일 삭제
            for fileURL in sortedFiles {
                if directorySize <= maxCacheSize { break }
                
                let fileSize = fileURL.fileSize()
                try FileManager.default.removeItem(at: fileURL)
                directorySize -= fileSize
            }
        } catch {
            print("LRU 캐시 관리 실패:", error)
        }
    }
}

extension URL {
    func fileSize() -> Int {
        do {
            let resourceValues = try self.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
            return resourceValues.totalFileAllocatedSize ?? 0
        } catch {
            print("파일 크기 계산 실패:", error)
            return 0
        }
    }
    
    func accessDate() -> Date {
        do {
            let resourceValues = try self.resourceValues(forKeys: [.contentAccessDateKey])
            return resourceValues.contentAccessDate ?? .distantPast
        } catch {
            print("파일 접근 시간 정보 읽기 실패: \(error)")
            return .distantPast
        }
    }
}
