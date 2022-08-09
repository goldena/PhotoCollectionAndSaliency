//
//  UICollectionViewFlowLayout.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

extension UICollectionViewFlowLayout {

    static func photoCollectionFlowLayout(for windowBounds: CGSize) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 4

        let width = min(
            windowBounds.width,
            windowBounds.height
        )
        let imageSize = width / 4 - layout.minimumInteritemSpacing * 3

        layout.itemSize = CGSize(
            width: imageSize,
            height: imageSize
        )

        return layout
    }

}
