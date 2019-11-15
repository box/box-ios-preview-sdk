//
//  ThumbnailGridViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/1/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

protocol ThumbnailGridViewControllerDelegate: AnyObject {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectItemAt index: Int)
}

class ThumbnailGridViewController: UIViewController {
    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: thumbnailGridCollectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(ThumbnailGridCell.self)
        return collectionView
    }()

    private lazy var thumbnailGridCollectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        return layout
    }()

    private lazy var cellSize: CGSize = {
        let totalInsetSpace = thumbnailGridCollectionViewLayout.sectionInset.left
            + thumbnailGridCollectionViewLayout.sectionInset.right
            + (thumbnailGridCollectionViewLayout.minimumInteritemSpacing * CGFloat(numberOfPagesPerRow - 1))

        let targetCellSize = (collectionView.bounds.width - totalInsetSpace) / CGFloat(numberOfPagesPerRow)
        thumbnailGridCollectionViewLayout.minimumLineSpacing = thumbnailGridCollectionViewLayout.minimumInteritemSpacing
        return CGSize(width: targetCellSize, height: targetCellSize * 1.4)
    }()

    private var helper: ThumbnailGridHelper?
    private var numberOfPagesPerRow: Int {
        return UIDevice.current.orientation.isLandscape ? 5 : 3
    }

    weak var delegate: ThumbnailGridViewControllerDelegate?

    init(helper: ThumbnailGridHelper, delegate: ThumbnailGridViewControllerDelegate?) {
        self.helper = helper
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
}

// MARK: - Private helpers

private extension ThumbnailGridViewController {
    func setupView() {
        view.backgroundColor = .white
        setupCollectionView()
        setupNavigationItems()
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "dismiss", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain, target: self, action: #selector(close)
        )
    }

    @objc private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ThumbnailGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ThumbnailGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return helper?.itemCount ?? 0
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ThumbnailGridCell.self, indexPath: indexPath)
        // to prevent loading old image to reused cell we use tags and index for which image was originally downloaded
        cell.tag = indexPath.row
        helper?.getThumbnail(at: indexPath.row, ofSize: cellSize) { image in
            if image.index == cell.tag {
                cell.configure(with: image.image, page: "\(indexPath.row + 1)")
            }
        }
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.thumbnailGridViewController(self, didSelectItemAt: indexPath.row)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
