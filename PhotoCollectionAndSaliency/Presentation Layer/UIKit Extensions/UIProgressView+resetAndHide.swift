//
//  UIProgressView+resetAndHide.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

extension UIProgressView {

    func resetAndHide() {
        self.progress = 0
        self.isHidden = true
    }

}
