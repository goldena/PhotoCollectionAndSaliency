//
//  AppCoordinator.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos

final class AppCoordinator: Coordinator {

    private var appContext: AppContext

    init(appContext: AppContext) {
        self.appContext = appContext

        super.init()

        setupNavigationBarAppearance()
    }

    private func setupNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()

        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        navigationController.navigationBar.tintColor = .label
    }

    func start(
        in window: UIWindow,
        animated: Bool = true
    ) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let photoCollectionViewController = PhotoCollectionViewController(
            windowSize: window.bounds.size,
            photoService: appContext.photoService,
            delegate: self
        )
        
        navigationController.pushViewController(
            photoCollectionViewController,
            animated: animated
        )
    }

}

extension AppCoordinator: PhotoCollectionViewControllerDelegate {

    func didSelect(phAsset: PHAsset) {
        let photoViewController = PhotoViewController(
            phAsset: phAsset,
            photoService: appContext.photoService,
            saliencyService: appContext.saliencyService
        )

        navigationController.pushViewController(
            photoViewController,
            animated: true
        )
    }

}
