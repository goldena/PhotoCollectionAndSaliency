//
//  PhotoCollectionViewCell.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "PhotoCollectionViewCell"

    var localIdentifier: String?

    private lazy var thumbnailView = UIImageView {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(thumbnailView)

        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    func clearContent() {
        localIdentifier = nil

        DispatchQueue.main.async {
            self.thumbnailView.image = nil
        }
    }

    func setImage(_ uiImage: UIImage) {
        DispatchQueue.main.async {
            self.thumbnailView.image = uiImage
        }
    }

}
