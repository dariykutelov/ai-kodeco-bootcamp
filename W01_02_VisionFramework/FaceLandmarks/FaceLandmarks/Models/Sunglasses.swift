//
//  Sunglasses.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 19.10.25.
//

import Foundation

struct SunglassImage {
    let imageName: String
    let verticalTopToNoseOffset: Float
}

extension SunglassImage {
    static var demoSunglasses = [
        SunglassImage(imageName: "sunglasses-1", verticalTopToNoseOffset: 18),
        SunglassImage(imageName: "sunglasses-2", verticalTopToNoseOffset: 17),
        SunglassImage(imageName: "sunglasses-3", verticalTopToNoseOffset: 16.6),
        SunglassImage(imageName: "sunglasses-4", verticalTopToNoseOffset: 17),
        SunglassImage(imageName: "sunglasses-5", verticalTopToNoseOffset: 22),
        SunglassImage(imageName: "sunglasses-6", verticalTopToNoseOffset: 23),
        SunglassImage(imageName: "sunglasses-7", verticalTopToNoseOffset: 15.2),
        SunglassImage(imageName: "sunglasses-8", verticalTopToNoseOffset: 19),
        SunglassImage(imageName: "sunglasses-9", verticalTopToNoseOffset: 18),
        SunglassImage(imageName: "sunglasses-10", verticalTopToNoseOffset: 21.2)
    ]
}
