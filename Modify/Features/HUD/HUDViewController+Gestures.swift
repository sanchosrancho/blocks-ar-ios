//
//  HUDViewController+Gestures.swift
//  Modify
//
//  Created by Олег Адамов on 18.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit

extension HUDViewController {
    
    func setupTap() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch placeState {
        case .placing:
            break
        case .preview:
            delegate?.hudDidTapInPreview(gesture: gesture)
        case .editing:
            delegate?.hudDidTapInEditing(gesture: gesture, color: colorPicker.currentColor, editMode: editModeView.editMode)
        }
    }
    
    
    func setupPan() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.view)
        switch gesture.state {
        case .began:
            self.startYPan = location.y
            self.delegate?.hudPlaceWillChangeDistance()
        case .changed:
            var deltaY = (location.y - startYPan)/300
            deltaY = CGFloat(round(100 * deltaY) / 100)
            self.delegate?.hudPlaceChangeDistance(Float(deltaY))
        case .ended: break
        default: break
        }
    }
}
