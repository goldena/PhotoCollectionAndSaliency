//
//  VisionKitSaliencyService.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Vision

final class VisionKitSaliencyService: Service, SaliencyService {

    func getSaliencyFrames(
        image: UIImage,
        saliencyBase: SaliencyBase,
        _ completion: @escaping (Result<[CGRect], Error>) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(.failure(SaliencyServiceError.couldNotRetrieveCGImage))
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request: VNRequest

        switch saliencyBase {
        case .attention:
            request = VNGenerateAttentionBasedSaliencyImageRequest()

        case .objectness:
            request = VNGenerateObjectnessBasedSaliencyImageRequest()
        }

        // Does not run on a simulator without this flag, hits hardware limitations
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif

        try? requestHandler.perform([request])

        guard let result = request.results?.first as? VNSaliencyImageObservation,
              let salientObjects = result.salientObjects else {
            completion(.failure(SaliencyServiceError.noSaliencyResults))
            return
        }

        let imageSize = CGSize(
            width: image.size.width,
            height: image.size.height
        )

        var saliencyFrames: [CGRect] = []

        // draw rectangles around bounding boxes of observations
        salientObjects.forEach { object in
            let boundingBox = object.boundingBox

            let origin = CGPoint(
                x: boundingBox.origin.x * imageSize.width,
                y: imageSize.height - boundingBox.origin.y * imageSize.height
            )
            let size = CGSize(
                width: boundingBox.width * imageSize.width,
                height: -(boundingBox.height * imageSize.height)
            )

            saliencyFrames.append(
                CGRect(
                    origin: origin,
                    size: size
                )
            )
        }

        completion(.success(saliencyFrames))
    }


}
