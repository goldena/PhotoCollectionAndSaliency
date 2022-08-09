//
//  AppContext.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import CoreGraphics

final class AppContext: Context {

    let windowSize: CGSize

    let photoService: PhotoService
    let saliencyService: SaliencyService

    init(
        windowSize: CGSize,

        photoService: PhotoService,
        saliencyService: SaliencyService
    ) {
        self.windowSize = windowSize

        self.photoService = photoService
        self.saliencyService = saliencyService

        super.init(services: [photoService])
    }

}
