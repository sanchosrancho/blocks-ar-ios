//
//  ColorPickerView.swift
//  Modify
//
//  Created by Олег Адамов on 14.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit

private enum ColorPickerState {
    case open
    case closed
}

class ColorPickerView: UIView {
    
    var currentColor: UIColor {
        return UIColor.fromHex(colorData[selectedView.index])
    }
    

    init(position: CGPoint) {
        let size = selectedItemSize + 2 * borderSize
        let frame = CGRect(x: 0, y: 0, width: size , height: size)
        super.init(frame: frame)
        self.center = position
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        createColorViews()
        createBorderView()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    
    
    //MARK: - Private
    
    private let colorData = ["8ab432", "50a9b3", "ffa900", "fc5000", "1773bd"]
    private let selectedItemSize: CGFloat = 36
    private let borderSize: CGFloat = 5
    
    private var state = ColorPickerState.closed
    private var selectedView: ColorView!
    private var borderView: UIView!
    private var colorViews = [ColorView]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createColorViews() {
        for i in 0..<colorData.count {
            let frame = CGRect(x: borderSize, y: borderSize, width: selectedItemSize, height: selectedItemSize)
            let colorView = ColorView(frame: frame, index: i, hex: colorData[i])
            colorViews.append(colorView)
            self.addSubview(colorView)
        }
        selectedView = colorViews[0]
    }
    
    
    private func createBorderView() {
        let size = selectedItemSize + 2 * borderSize
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        let view = UIView(frame: frame)
        view.layer.cornerRadius = size/2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = borderSize
        view.backgroundColor = currentColor
        self.addSubview(view)
        self.borderView = view
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch state {
        case .closed: showAllViews()
        case .open: break
        }
    }
    
    
    private func showAllViews() {
        
    }
}


private class ColorView: UIView {
    
    let index: Int
    var selected = false
    
    init(frame: CGRect, index: Int, hex: String) {
        self.index = index
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.width/2
        self.backgroundColor = UIColor.fromHex(hex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
