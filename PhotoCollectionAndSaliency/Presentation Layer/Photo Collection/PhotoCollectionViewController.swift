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

    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout.photoCollectionFlowLayout(for: windowSize)
    private lazy var thumbnailSize = collectionViewFlowLayout.itemSize

    private weak var photoService: PhotoService?
    private weak var delegate: PhotoCollectionViewControllerDelegate?

    private var assets = PHFetchResult<PHAsset>()

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

        fetchThumbnails()
    }

    private func fetchThumbnails() {
        photoService?.requestAuthorization { [weak self] isAuthorized in
            guard let self = self,
                  isAuthorized else {
                return
            }

            self.fetchPHAssets()
        }
    }

    private func fetchPHAssets() {
        self.photoService?.requestPHAssets(last: AppEnvironment.photoCollection.quantityOfPhotos) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let phAssets):
                self.assets = phAssets

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }

            case .failure(let error):
                print("Failed to fetch thumbnails with \(error.localizedDescription)")
            }
        }
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

        let phAsset = assets[indexPath.item]

        photoCell.localIdentifier = phAsset.localIdentifier

        photoService?.requestThumbnail(
            phAsset: phAsset,
            targetSize: thumbnailSize
        ) { result in
            switch result {
            case .success(let uiImage):
                if let uiImage = uiImage,
                   photoCell.localIdentifier == phAsset.localIdentifier {
                    photoCell.setImage(uiImage)
                }

            case .failure(let error):
                print("Failed to fetch \(phAsset), with \(error)")
            }
        }

        return photoCell
    }

}

// MARK: UICollectionViewDelegate

extension PhotoCollectionViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        delegate?.didSelect(phAsset: assets[indexPath.item])

        return false
    }

}
