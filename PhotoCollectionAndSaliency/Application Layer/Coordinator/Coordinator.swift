//
//  Coordinator.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

class Coordinator: NSObject {

    private(set) var coordinator: Coordinator?
    private(set) var navigationController: UINavigationController

    init(parent coordinator: Coordinator? = nil) {
        self.coordinator = coordinator
        self.navigationController = UINavigationController()

        super.init()

        navigationController.delegate = self
    }

    func start(animated: Bool = true) {
        print("--> Warning 'start()' is not overridden in \(self)")
    }

    #if DEBUG
    deinit {
        print("--> \(self) deinitialized")
    }
    #endif

}

extension Coordinator: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: nil,
            style: .plain,
            target: nil,
            action: nil
        )
    }

}
