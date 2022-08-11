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
        requestOptions.deliveryMode = .highQualityFormat

        DispatchQueue.main.async { [weak self] in
            self?.phCachingImageManager.requestImage(
                for: phAsset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: requestOptions
            ) { uiImage, info in
                // Reproducible on the simulator, after logging into someone's account
                if info?[PHImageResultIsInCloudKey] as? Bool != nil {
                    print("--> thumbnail is in the iCloud")
                }

                if let uiImage = uiImage {
                    completion(.success(uiImage))
                }
            }
        }
    }

    func requestImage(
        phAsset: PHAsset,
        requestOwner: AppViewController?,
        _ completion: @escaping (Result<(progress: Double, UIImage?), Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(PhotoServiceError.notAuthorized))
            return
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat

        requestOptions.progressHandler = { [weak requestOwner] (progress, error, stop, _) in
            guard requestOwner != nil else {
                stop.pointee = true
                print("--> Image download cancelled")
                return
            }

            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch \(phAsset), with error: \(error.localizedDescription)")
                    completion(.failure(PhotoServiceError.failedToFetchPhoto))
                } else {
                    completion(.success((progress: progress, nil)))
                }
            }
        }

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.phCachingImageManager.requestImage(
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

    func startCachingPHAssets(
        _ phAssets: [PHAsset],
        size: CGSize
    ) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .fastFormat

        phCachingImageManager.startCachingImages(
            for: phAssets,
            targetSize: size,
            contentMode: .aspectFit,
            options: requestOptions
        )
    }

    func stopCachingPHAssets(
        _ phAssets: [PHAsset],
        size: CGSize
    ) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .fastFormat

        phCachingImageManager.stopCachingImages(
            for: phAssets,
            targetSize: size,
            contentMode: .aspectFit,
            options: requestOptions
        )
    }

}
