//
//  SinglePhotoPicker.swift
//  Gathering
//
//  Created by 여성은 on 12/13/24.
//

import PhotosUI
import SwiftUI

public struct SinglePhotoPicker<Content: View>: View {
    @State private var selectedPhotos: [PhotosPickerItem]
    @Binding private var selectedImages: [UIImage]?
    @Binding private var isPresentedError: Bool
    
    private let maxSelectedCount: Int
//    private var disabled: Bool {
//        return selectedPhotos.count >= maxSelectedCount
//    }
    private var disabled: Bool {
        return selectedImages?.count ?? 0 >= maxSelectedCount
    }
    private var availableSelectedCount: Int {
        return maxSelectedCount - (selectedImages?.count ?? 0 )
    }
    private let matching: PHPickerFilter
    private let photoLibrary: PHPhotoLibrary
    private let content: () -> Content
    
    public init(
        selectedPhotos: [PhotosPickerItem] = [],
        selectedImages: Binding<[UIImage]?>,
        isPresentedError: Binding<Bool> = .constant(false),
        maxSelectedCount: Int = 1,
        matching: PHPickerFilter = .images,
        photoLibrary: PHPhotoLibrary = .shared(),
        content: @escaping () -> Content
    ) {
        self.selectedPhotos = selectedPhotos
        self._selectedImages = selectedImages
        self._isPresentedError = isPresentedError
        self.maxSelectedCount = maxSelectedCount
        self.matching = matching
        self.photoLibrary = photoLibrary
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: availableSelectedCount,
                matching: matching,
                photoLibrary: photoLibrary
            ) {
                content()
//                    .disabled(disabled)
            }
//            .disabled(disabled)
            .onChange(of: selectedPhotos) {
                handleSelectedPhotos(selectedPhotos)
            }
        } else {
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: availableSelectedCount,
                matching: matching,
                photoLibrary: photoLibrary
            ) {
                content()
                    .disabled(disabled)
            }
            .disabled(disabled)
            .onChange(of: selectedPhotos) { newValue in
                handleSelectedPhotos(newValue)
            }
        }
    }
    
    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) {
        for newPhoto in newPhotos {
            newPhoto.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let newImage = UIImage(data: data) {
                        if !(selectedImages?.contains(
                            where: { $0.pngData() == newImage.pngData() }) ?? true
                        ) {
                            DispatchQueue.main.async {
                                selectedImages?.append(newImage)
                            }
                        }
                    }
                case .failure:
                    isPresentedError = true
                }
            }
        }
        
//        selectedPhotos.removeAll()
    }
}
