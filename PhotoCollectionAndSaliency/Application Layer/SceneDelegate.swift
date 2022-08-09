//
//  SceneDelegate.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: scene)
        guard let window = window else {
            return
        }

        let context = AppContext(
            windowSize: window.bounds.size,
            photoService: PHPhotoLibraryService()
        )
        context.startServices()

        appCoordinator = AppCoordinator(appContext: context)
        appCoordinator?.start(in: window)
    }

}
