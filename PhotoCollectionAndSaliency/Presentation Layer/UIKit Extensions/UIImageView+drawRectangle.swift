//
//  UIImageView+drawRectangle.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

extension UIImageView {

    func drawRectangle(
        color: UIColor,
        lineWidth: CGFloat,
        rect: CGRect
    ) {
        guard let image = self.image else {
            return
        }

        UIGraphicsBeginImageContext(image.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        defer {
            UIGraphicsEndImageContext()
        }

        image.draw(at: CGPoint.zero)

        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.stroke(rect)

        if let imageWithRect = UIGraphicsGetImageFromCurrentImageContext() {
            self.image = imageWithRect
        }
    }

}
