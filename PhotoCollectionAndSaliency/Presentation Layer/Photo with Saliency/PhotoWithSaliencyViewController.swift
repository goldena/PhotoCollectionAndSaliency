//
//  PhotoViewController.swift
//  PhotoCollectionAndSaliency
//
//  Created by Denis Goloborodko on 9.08.22.
//

import UIKit
import Photos
import AVFoundation

final class PhotoWithSaliencyViewController: AppViewController {

    private let phAsset: PHAsset
    private weak var photoService: PhotoService?
    private weak var saliencyService: SaliencyService?

    private lazy var imageView = UIImageView {
        $0.contentMode = .scaleAspectFit
    }

    private lazy var progressView = UIProgressView {
        $0.isHidden = true
    }

    init(
        phAsset: PHAsset,
        photoService: PhotoService,
        saliencyService: SaliencyService
    ) {
        self.phAsset = phAsset
        self.photoService = photoService
        self.saliencyService = saliencyService

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
        guard let image = imageView.image else {
            print("--> image in imageView is nil")
            return
        }

        let frame = AVMakeRect(
            aspectRatio: image.size,
            insideRect: imageView.bounds
        )

        let scaleRatio: CGFloat
        if view.bounds.width > view.bounds.height {
            scaleRatio = view.bounds.width / frame.width
        } else {
            scaleRatio = view.bounds.height / frame.height
        }

        let scaleTransform: CGAffineTransform
        switch imageView.contentMode {
        case .scaleAspectFit:
            scaleTransform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)

        case .scaleAspectFill:
            scaleTransform = CGAffineTransform(scaleX: 1 / scaleRatio, y: 1 / scaleRatio)

        default:
            return
        }

        UIView.animate(withDuration: 0.5) {
            self.imageView.transform = scaleTransform
        } completion: { completed in
            if completed {
                self.imageView.transform = .identity

                if self.imageView.contentMode == .scaleAspectFit {
                    self.imageView.contentMode = .scaleAspectFill
                } else {
                    self.imageView.contentMode = .scaleAspectFit
                }
            }
        }
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
                            self.progressView.resetAndHide()

                            self.imageView.image = image
                            self.drawSaliencyFrames()
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

    private func drawSaliencyFrames(base: SaliencyBase = .attention) {
        guard let image = imageView.image else {
            print("--> image in imageView is nil")
            return
        }

        saliencyService?.getSaliencyFrames(
            image: image,
            saliencyBase: base
        ) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let saliencyFrames):
                saliencyFrames.forEach { rect in
                    self.imageView.drawRectangle(
                        color: .red,
                        lineWidth: 0.005 * image.size.width,
                        rect: CGRect(origin: rect.origin, size: rect.size)
                    )
                }

            case .failure(let error):
                print("--> failed to get saliency frames with error: \(error.localizedDescription)")
            }
        }

    }

}
