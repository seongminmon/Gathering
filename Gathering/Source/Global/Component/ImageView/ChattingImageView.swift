//
//  ChattingImageView.swift
//  Gathering
//
//  Created by 여성은 on 11/8/24.
//

import SwiftUI

struct ChattingImageView: View {
    var imageNames: [String]
    
    var body: some View {
        if imageNames.count == 2 || imageNames.count == 3 {
            HStack {
                if imageNames.count == 2 {
                    twoImages(imageNames)
                } else {
                    threeImages(imageNames)
                }
            }
            .frame(width: 243, height: 80)
            .background(Design.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            HStack {
                if imageNames.count == 1 {
                    oneImage(imageNames)
                } else if imageNames.count == 4 {
                    fourImages(imageNames)
                } else {
                    fiveImages(imageNames)
                }
            }
            .frame(width: 243, height: 161)
            .background(Design.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func oneImage(_ imageStr: [String]) -> some View {
        CustomizableImageView(
            urlString: imageStr[0],
            width: 244,
            height: 162,
            cornerRadius: 12
        )
    }
    private func twoImages(_ imageStr: [String]) -> some View {
        HStack(spacing: 1) {
            CustomizableImageView(
                urlString: imageStr[0],
                width: 121,
                height: 80,
                cornerRadius: 4
            )
            CustomizableImageView(
                urlString: imageStr[1],
                width: 121,
                height: 80,
                cornerRadius: 4
            )
        }
    }
    
    private func threeImages(_ imageStr: [String]) -> some View {
        HStack(spacing: 1) {
            CustomizableImageView(
                urlString: imageStr[0],
                width: 80,
                height: 80,
                cornerRadius: 4
            )
            CustomizableImageView(
                urlString: imageStr[1],
                width: 80,
                height: 80,
                cornerRadius: 4
            )
            CustomizableImageView(
                urlString: imageStr[2],
                width: 80,
                height: 80,
                cornerRadius: 4
            )
        }
    }
    
    private func fourImages(_ imageStr: [String]) -> some View {
        let firstPart = Array(imageStr.prefix(2))
        let secondPart = Array(imageStr.suffix(imageStr.count - 2))
        return VStack(spacing: 1) {
            twoImages(firstPart)
            twoImages(secondPart)
        }
    }
    
    private func fiveImages(_ imageStr: [String]) -> some View {
        let firstPart = Array(imageStr.prefix(2))
        let secondPart = Array(imageStr.suffix(imageStr.count - 2))
        return VStack(spacing: 1) {
            twoImages(firstPart)
            threeImages(secondPart)
        }
    }
}
