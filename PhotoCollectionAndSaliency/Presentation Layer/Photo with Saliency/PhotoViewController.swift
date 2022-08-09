//
//  PhotoViewController.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos

final class PhotoViewController: AppViewController {

    private let phAsset: PHAsset
    private weak var photoService: PhotoService?

    private lazy var imageView = UIImageView {
        $0.contentMode = .scaleAspectFit
    }

    private lazy var progressView = UIProgressView {
        $0.isHidden = true
    }

    init(
        phAsset: PHAsset,
        photoService: PhotoService
    ) {
        self.phAsset = phAsset
        self.photoService = photoService

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        fetchImage(for: phAsset)
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: AppEnvironment.photoView.toggleContentModeSFSymbol),
            style: .plain,
            target: self,
            action: #selector(toggleContentMode)
        )

        view.backgroundColor = .systemBackground

        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }

    @objc private func toggleContentMode() {
        fatalError("not implemented")
    }

    private func fetchImage(for phAsset: PHAsset) {
        self.progressView.isHidden = false

        photoService?.requestThumbnail(
            phAsset: phAsset,
            targetSize: PHImageManagerMaximumSize) { [weak self] result in
                guard let self = self else {
                    return
                }

                switch result {
                case .success(let image):
                    self.imageView.image = image

                case .failure(let error):
                    print("Failed to fetch low definition image \(phAsset) with \(error)")
                }

                self.photoService?.requestImage(phAsset: phAsset) { [weak self] result in
                    guard let self = self else {
                        return
                    }

                    switch result {
                    case .success((let progress, let image)):
                        if let image = image {
                            self.imageView.image = image
                            self.progressView.resetAndHide()
                        } else {
                            self.progressView.progress = Float(progress)
                        }

                    case .failure(let error):
                        self.progressView.resetAndHide()
                        print("Failed to fetch high definition image \(phAsset) with \(error)")
                    }
                }
            }
    }


}
