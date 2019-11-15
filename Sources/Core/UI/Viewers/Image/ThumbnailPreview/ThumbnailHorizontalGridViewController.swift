//
//  ThumbnailPreviewViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/8/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

protocol ThumbnailHorizontalGridDelegate: AnyObject {
    func thumbnailPreview(_ viewController: ThumbnailHorizontalGridViewController, didSelectItemAtIndex index: Int)
}

class ThumbnailHorizontalGridViewController: UIViewController {

    weak var delegate: ThumbnailHorizontalGridDelegate?

    private let thumbnailHelper: ThumbnailPreviewHelper
    private lazy var collectionView: UICollectionView = {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        horizontalLayout.minimumInteritemSpacing = 1
        horizontalLayout.minimumLineSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = false
        collectionView.registerClass(ThumbnailPreviewCell.self)
        return collectionView
    }()

    private var selectedIndexPath: IndexPath

    private lazy var selectedItemSize: CGSize = {
        makeCellSize(withMargin: 2.0)
    }()

    private lazy var itemSize: CGSize = {
        makeCellSize(withMargin: 20.0)
    }()

    private let cellMargin: Int = 1

    // MARK: - Lifecycle

    init(thumbnailHelper: ThumbnailPreviewHelper) {
        self.thumbnailHelper = thumbnailHelper
        selectedIndexPath = IndexPath(item: thumbnailHelper.selectedIndex, section: 0)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSelection(to: selectedIndexPath)
    }

    // MARK: - Cell selection
    func selectThumbnail(at index: Int) {
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        updateSelection(to: index)
    }

    private func updateSelection(to index: Int) {
        let newIndexPath = IndexPath(item: index, section: 0)
        updateSelection(to: newIndexPath)
    }

    private func updateSelection(to indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            return
        }
        let previousIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else {
                return
            }
            self.collectionView.reloadItems(at: [self.selectedIndexPath, previousIndexPath])
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ThumbnailHorizontalGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return thumbnailHelper.itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ThumbnailPreviewCell.self, indexPath: indexPath)
        cell.tag = indexPath.row
        thumbnailHelper.getThumbnailImage(ofMaxHeight: 200, maxWidth: 150, atIndex: indexPath.row) { result in
            switch result {
            case let .success(result):
                // to prevent old image from previous cell image request to show up
                if result.index == cell.tag {
                    cell.thumbnailImageView.image = result.image
                }
            case .failure:
                cell.thumbnailImageView.image = UIImage(named: "error")
            }
        }
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.thumbnailPreview(self, didSelectItemAtIndex: indexPath.row)
        updateSelection(to: indexPath)
    }
}

extension ThumbnailHorizontalGridViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == selectedIndexPath {
            return selectedItemSize
        }
        return itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        let allCellsWidth: CGFloat =
            // calculating space taken by not selected cells
            itemSize.width * CGFloat(thumbnailHelper.itemCount - 1) +
            // space taken by selected cell
            selectedItemSize.width +
            // adding size of a margin
            CGFloat(thumbnailHelper.itemCount * cellMargin)
        let horizontalInsetsSize = collectionView.frame.width - allCellsWidth
        return horizontalInsetsSize > 0 ?
            UIEdgeInsets(top: 0, left: horizontalInsetsSize / 2, bottom: 0, right: 0) :
            .zero
    }
}

// MARK: - Layout

private extension ThumbnailHorizontalGridViewController {

    func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func makeCellSize(withMargin margin: CGFloat) -> CGSize {
        let height: CGFloat = collectionView.frame.height - margin
        let width: CGFloat = height / 1.4
        return CGSize(width: width, height: height)
    }
}
