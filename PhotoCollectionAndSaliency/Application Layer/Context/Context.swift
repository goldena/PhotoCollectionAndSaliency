//
//  Context.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

class Context {

    private var services: [Service] = []

    func startServices() {
        services.forEach {
            $0.start()
        }
    }

    func stopServices() {
        services.forEach {
            $0.stop()
        }
    }

    init(services: [Service]) {
        self.services = services
    }

}
