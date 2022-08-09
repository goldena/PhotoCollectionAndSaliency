//
//  PhotoService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos

enum PhotoServiceError: Error {
    case notAuthorized
    case failedToFetchPhoto
}

protocol PhotoService: Service {

    var isAuthorized: Bool { get }

    func requestAuthorization(_ completion: @escaping (Bool) -> Void)

    func requestPHAssets(
        last numberOfPHAssets: Int,
        _ completion: @escaping (Result<PHFetchResult<PHAsset>, Error>) -> Void
    )

    func requestThumbnail(
        phAsset: PHAsset,
        targetSize: CGSize,
        _ completion: @escaping (Result<UIImage?, Error>) -> Void
    )

    func requestImage(
        phAsset: PHAsset,
        _ completion: @escaping (Result<(progress: Double, UIImage?), Error>) -> Void
    )

    func startCachingPHAssets(
        _ phAssets: [PHAsset],
        size: CGSize
    )

    func stopCachingPHAssets(
        _ phAssets: [PHAsset],
        size: CGSize
    )

}
