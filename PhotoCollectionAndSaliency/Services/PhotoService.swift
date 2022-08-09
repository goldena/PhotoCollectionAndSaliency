//
//  PhotoService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import Photos

enum PhotoServiceError: Error {
    case notAuthorized
}

protocol PhotoService: Service {

    var isAuthorized: Bool { get }
    func requestAuthorization(_ completion: @escaping (Bool) -> Void)

}
