//
//  ImageScrollView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 6/26/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var zoomView: UIImageView!
    public lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()

    // swiftlint:disable:next unavailable_function
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        contentInsetAdjustmentBehavior = .never
        delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerImage()
    }

    // MARK: - Configure scrollView to display new image

    func display(_ image: UIImage) {

        // 1. clear the previous image
        zoomView?.removeFromSuperview()
        zoomView = nil

        // 2. make a new UIImageView for the new image
        zoomView = UIImageView(image: image)
        addSubview(zoomView)

        configureFor(image.size)
    }

    func configureFor(_ imageSize: CGSize) {
        contentSize = imageSize
        setMaxMinZoomScaleForCurrentBounds()
        zoomScale = minimumZoomScale

        // Enable zoom tap
        zoomView.addGestureRecognizer(zoomingTap)
        zoomView.isUserInteractionEnabled = true
    }

    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = bounds.size
        let imageSize = zoomView.bounds.size

        // 1. calculate minimumZoomscale
        let xScale = boundsSize.width / imageSize.width // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height // the scale needed to perfectly fit the image height-wise
        let minScale = min(xScale, yScale) // use minimum of these to allow the image to become fully visible

        // 2. calculate maximumZoomscale
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1, minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }

        maximumZoomScale = maxScale
        minimumZoomScale = minScale
    }

    func centerImage() {

        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize = bounds.size
        var frameToCenter = zoomView?.frame ?? CGRect.zero

        // center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }

        // center vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }

        zoomView?.frame = frameToCenter
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in _: UIScrollView) -> UIView? {
        return zoomView
    }

    func scrollViewDidZoom(_: UIScrollView) {
        centerImage()
    }

    // MARK: - Preserve the zoomScale and the visible portion of the image

    // returns the center point, in image coordinate space, to try restore after rotation.
    func pointToCenterAfterRotation() -> CGPoint {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        return convert(boundsCenter, to: zoomView)
    }

    // returns the zoom scale to attempt to restore after rotation.
    func scaleToRestoreAfterRotation() -> CGFloat {
        var contentScale = zoomScale
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if contentScale <= minimumZoomScale + CGFloat.ulpOfOne {
            contentScale = 0
        }
        return contentScale
    }

    func maximumContentOffset() -> CGPoint {
        let contentSize = self.contentSize
        let boundSize = bounds.size
        return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
    }

    func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }

    func restoreCenterPoint(to oldCenter: CGPoint, oldScale: CGFloat) {
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        zoomScale = min(maximumZoomScale, max(minimumZoomScale, oldScale))

        // Step 2: restore center point, first making sure it is within the allowable range.
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter = convert(oldCenter, from: zoomView)
        // 2b: calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width / 2.0, y: boundsCenter.y - bounds.size.height / 2.0)
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))

        contentOffset = offset
    }

    // MARK: - Handle Zooming Tap

    @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoom(to: location, animated: true)
    }
}
