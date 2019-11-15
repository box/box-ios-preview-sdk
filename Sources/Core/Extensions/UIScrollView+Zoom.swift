//
//  UIScrollView+Zoom.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/2/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

extension UIScrollView {
    func zoom(to point: CGPoint, animated: Bool, forceZoomInMax: Bool = false) {
        let currentScale = zoomScale
        let minScale = minimumZoomScale
        let maxScale = maximumZoomScale

        if minScale == maxScale, minScale > 1 {
            return
        }
        var finalScale: CGFloat

        if forceZoomInMax {
            finalScale = maxScale
        } else {
            finalScale = (currentScale == minScale) ? maxScale : minScale
        }
        let zoomRect = self.zoomRect(for: finalScale, withCenter: point)
        zoom(to: zoomRect, animated: animated)
    }
    
    func move(to point: CGPoint, animated: Bool) {
        var scale = zoomScale
        if scale != maximumZoomScale {
            scale = maximumZoomScale
        }
        let zoomRect = self.zoomRect(for: scale, withCenter: point)
        zoom(to: zoomRect, animated: animated)
    }

    // The center should be in the imageView's coordinates
    func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds

        // the zoom rect is in the content view's coordinates.
        // At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale

        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}
