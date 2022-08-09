//
//  PHCachingImageManagerService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos

final class PHCachingImageManagerService: Service, PhotoService {

    private let phCachingImageManager = PHCachingImageManager()

    var isAuthorized: Bool {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch authorizationStatus {
        case .authorized, .limited:
            return true

        case .notDetermined, .restricted, .denied:
            return false

        @unknown default:
            fatalError("Unknown case of authorisation to use photo library: \(authorizationStatus)")
        }
    }

    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        if isAuthorized {
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                completion(self.isAuthorized)
            }
        }
    }

    func requestPHAssets(
        last fetchLimit: Int,
        _ completion: @escaping (Result<PHFetchResult<PHAsset>, Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(PhotoServiceError.notAuthorized))
            return
        }

        let fetchOptions = PHFetchOptions()

        fetchOptions.fetchLimit = fetchLimit
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        DispatchQueue.main.async {
            let phAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            completion(.success(phAssets))
        }
    }
    
    func requestThumbnail(
        phAsset: PHAsset,
        targetSize: CGSize,
        _ completion: @escaping (Result<UIImage?, Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(PhotoServiceError.notAuthorized))
            return
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .fastFormat

        DispatchQueue.main.async {
            PHCachingImageManager.default().requestImage(
                for: phAsset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: requestOptions
            ) { uiImage, info in
                // Hard to reproduce - all the thumbnails are usually in memory
                if let isIniCloud = info?[PHImageResultIsInCloudKey] as? Bool {
                    print(isIniCloud)
                }

                if let uiImage = uiImage {
                    completion(.success(uiImage))
                }
            }
        }
    }

    func requestImage(
        phAsset: PHAsset,
        _ completion: @escaping (Result<(progress: Double, UIImage?), Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(PhotoServiceError.notAuthorized))
            return
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat

        requestOptions.progressHandler = { (progress, error, _, _) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch \(phAsset), with error: \(error.localizedDescription)")
                    completion(.failure(PhotoServiceError.failedToFetchPhoto))
                } else {
                    completion(.success((progress: progress, nil)))
                }
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            PHCachingImageManager.default().requestImage(
                for: phAsset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: requestOptions
            ) { uiImage, _ in
                if let uiImage = uiImage {
                    completion(.success((progress: 1.0, uiImage)))
                }
            }
        }
    }
}
