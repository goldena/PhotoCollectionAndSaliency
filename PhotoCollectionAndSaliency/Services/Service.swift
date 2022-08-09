//
//  Service.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import Foundation

class Service: NSObject {

    func start() {
        print("--> Warning, 'start()' not overridden in \(self.description)")
    }

    func stop() {
        print("--> Warning, 'stop()' not overridden in \(self.description)")
    }

    #if DEBUG
    deinit {
        print("--> \(self.description) deinitialized")
    }
    #endif

}
