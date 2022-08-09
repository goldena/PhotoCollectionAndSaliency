//
//  PHPhotoLibraryService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import Photos

final class PHPhotoLibraryService: Service, PhotoService {

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

}
