//
//  EditModeView.swift
//  Modify
//
//  Created by Олег Адамов on 25.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


enum EditModeType {
    case append
    case delete
}


class EditModeView: UIView {

    var editMode: EditModeType = .append
    
    
    init(position: CGPoint) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        super.init(frame: frame)
        
        self.center = position
        self.layer.cornerRadius = height/2
        self.backgroundColor = .white
        
        fillXMovePositions()
        setupIndicatorView()
        setupIcons()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gesture)
        
        updateAppearance(animated: false)
    }
    
    
    //MARK: - Private
    
    private let width: CGFloat = 116
    private let height: CGFloat = 60
    private let itemSize: CGFloat = 48
    private var xMovePositions = [CGFloat]()
    private var indicatorView: UIView?
    private var iconImageViews = [UIImageView]()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updateAppearance(animated: Bool) {
        let closure = {
            switch self.editMode {
            case .append:
                self.indicatorView?.center = CGPoint(x: self.xMovePositions[1], y: self.height/2)
                self.iconImageViews[0].tintColor = .innerGray
                self.iconImageViews[1].tintColor = .white
            case .delete:
                self.indicatorView?.center = CGPoint(x: self.xMovePositions[0], y: self.height/2)
                self.iconImageViews[0].tintColor = .white
                self.iconImageViews[1].tintColor = .innerGray
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseInOut, animations: closure, completion: nil)
        }
        else {
            closure()
        }
    }
    
    
    private func fillXMovePositions() {
        let padding = (height - itemSize)/2
        xMovePositions.append(padding + itemSize/2)
        xMovePositions.append(width - padding - itemSize/2)
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x
        let mode: EditModeType = x < self.bounds.width/2 ? .delete : .append
        
        guard mode != self.editMode else { return }
        
        self.editMode = mode
        updateAppearance(animated: true)
    }
    
    
    private func setupIndicatorView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: itemSize, height: itemSize))
        view.center = CGPoint(x: xMovePositions[1], y: height/2)
        view.backgroundColor = .innerGray
        view.layer.cornerRadius = itemSize/2
        
        self.addSubview(view)
        self.indicatorView = view
    }
    
    
    private func setupIcons() {
        let names = ["btn_edit_delete", "btn_edit_append"]
        for i in 0..<2 {
            let image = UIImage(named: names[i])
            let imView = UIImageView(image: image)
            imView.center = CGPoint(x: xMovePositions[i], y: height/2)
            self.addSubview(imView)
            iconImageViews.append(imView)
        }
    }
}
