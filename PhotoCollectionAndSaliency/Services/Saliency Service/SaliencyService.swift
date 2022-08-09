//
//  SaliencyService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

enum SaliencyServiceError: Error {
    case couldNotRetrieveCGImage
    case noSaliencyResults
}

enum SaliencyBase {
    case attention
    case objectness
}

protocol SaliencyService: Service {

    func getSaliencyFrames(
        image: UIImage,
        saliencyBase: SaliencyBase,
        _ completion: @escaping (Result<[CGRect], Error>) -> Void
    )

}
