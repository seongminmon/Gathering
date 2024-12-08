//
//  ImageFileManager.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import UIKit

// 파일 매니저에 이미지를 추가 / 삭제하는 시점 >> DB에 저장하는 시점과 동기화

final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() {}
    
    // 도큐먼트 폴더 위치
    private let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first
    
    private var imageDirectory: URL? {
        return documentDirectory?.appendingPathComponent("CachedImages")
    }
    
    /// 이미지 폴더 생성
    func createImageDirectory() {
        guard let imageDirectory else {
            print("이미지 폴더 경로를 생성할 수 없음")
            return
        }
        
        if FileManager.default.fileExists(atPath: imageDirectory.path) {
            print("CachedImages 폴더가 이미 존재합니다.")
        } else {
            do {
                try FileManager.default.createDirectory(
                    at: imageDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("CachedImages 폴더 생성 완료")
            } catch {
                print("CachedImages 폴더 생성 실패:", error)
            }
        }
    }
    
    /// 이미지로 저장
    func saveImageFile(filename: String, image: UIImage) async {
        print(#function)
        
        guard let imageDirectory else {
            print("이미지 폴더 없음")
            return
        }
        
        let fileURL = imageDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        do {
            try data.write(to: fileURL)
            print("이미지 파일 저장 성공")
        } catch {
            print("이미지 파일 저장 실패", error)
        }
    }
    
    /// 파일 이름으로 저장 (내부에서 통신)
    func saveImageFile(filename: String) async {
        print(#function)
        
        guard let imageDirectory else {
            print("이미지 폴더 없음")
            return
        }
        
        let fileURL = imageDirectory.appendingPathComponent(filename)
        do {
            let image = try await NetworkManager.shared.requestImage(
                ImageRouter.fetchImage(path: filename)
            )
            guard let data = image.jpegData(compressionQuality: 0.5) else { return }
            do {
                try data.write(to: fileURL)
                print("이미지 파일 저장 성공")
            } catch {
                print("이미지 파일 저장 실패", error)
            }
        } catch {
            print("이미지 파일 통신 실패")
        }
    }
    
    func loadImageFile(filename: String) -> UIImage? {
        guard let imageDirectory else {
            print("이미지 폴더 없음")
            return nil
        }
        let fileURL = imageDirectory.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return nil
        }
    }
    
    func deleteImageFile(filename: String) {
        guard let imageDirectory else {
            print("이미지 폴더 없음")
            return
        }
        let fileURL = imageDirectory.appendingPathComponent(filename)
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
        guard let imageDirectory else {
            print("이미지 폴더 없음")
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: imageDirectory,
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
