//
//  PhotoCollectionViewController.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos

protocol PhotoCollectionViewControllerDelegate: AnyObject {
    func didSelect(phAsset: PHAsset)
}

final class PhotoCollectionViewController: AppViewController {

    private let windowSize: CGSize

    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = .photoCollectionFlowLayout(for: windowSize)
    private lazy var thumbnailSize = collectionViewFlowLayout.itemSize

    private weak var photoService: PhotoService?
    private weak var delegate: PhotoCollectionViewControllerDelegate?

    private var assets: [Int] = Array(repeating: 0, count: 10_000)

    private var collectionView: UICollectionView {
        view as! UICollectionView
    }

    init(
        windowSize: CGSize,
        photoService: PhotoService,
        delegate: PhotoCollectionViewControllerDelegate
    ) {
        self.windowSize = windowSize
        self.photoService = photoService
        self.delegate = delegate

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewFlowLayout
        )

        self.view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Recents", comment: "\(self.description) Navigation Title")

        collectionView.register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

// MARK: UICollectionViewDataSource

extension PhotoCollectionViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        assets.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let photoCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError("Failed to downcast cell to \(String(describing: PhotoCollectionViewCell.self))")
        }

        photoCell.clearContent()
        photoCell.backgroundColor = .blue

        let phAsset = assets[indexPath.item]

        // photoCell.localIdentifier = phAsset.localIdentifier

        return photoCell
    }

}

// MARK: UICollectionViewDelegate

extension PhotoCollectionViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        // delegate?.didSelect(phAsset: assets[indexPath.item])

        return false
    }

}
