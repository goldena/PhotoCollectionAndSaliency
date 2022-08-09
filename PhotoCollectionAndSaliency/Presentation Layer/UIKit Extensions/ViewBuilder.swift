//
//  ViewBuilder.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

extension UIView {

    convenience init(_ closure: (Self) -> Void) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false

        closure(self)
    }

}
