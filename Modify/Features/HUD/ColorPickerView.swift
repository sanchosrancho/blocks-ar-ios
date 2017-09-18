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
        let frame = CGRect(x: 0, y: 0, width: itemSize , height: itemSize)
        super.init(frame: frame)
        self.center = position
        self.clipsToBounds = false
        
        createColorViews()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    
    //MARK: - Private
    
    private let colorData = ["8ab432", "50a9b3", "ffa900", "fc5000", "1773bd"]
    private let itemSize: CGFloat = 46
    private let itemsPadding: CGFloat = 2
    
    private var state = ColorPickerState.closed
    private var selectedView: ColorView!
    private var borderView: UIView!
    private var colorViews = [ColorView]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createColorViews() {
        for i in 0..<colorData.count {
            let frame = CGRect(x: 0, y: 0, width: itemSize, height: itemSize)
            let colorView = ColorView(frame: frame, index: i, hex: colorData[i])
            colorViews.append(colorView)
            self.addSubview(colorView)
        }
        // important to select last
        colorViews[colorData.count - 1].selected = true
        selectedView = colorViews[colorData.count - 1]
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch state {
        case .closed:
            state = .open
            showAllViews()
        case .open:
            let location = gesture.location(in: self)
            for view in colorViews {
                guard view.frame.contains(location), view != selectedView else { continue }
                updateNewColorView(view)
                break
            }
            state = .closed
            hideAllViews()
        }
    }
    
    
    private func updateNewColorView(_ newView: ColorView) {
        selectedView.selected = false
        newView.selected = true
        colorViews.remove(object: newView)
        colorViews.append(newView)
        self.bringSubview(toFront: newView)
        selectedView = newView
    }
    
    
    private func showAllViews() {
        let newHeight = CGFloat(colorData.count) * itemSize + CGFloat(colorData.count - 1) * itemsPadding
        let deltaY = newHeight - self.bounds.height
        var frame = self.frame
        frame.origin.y -= deltaY
        frame.size.height = newHeight
        self.frame = frame
        for view in self.subviews {
            var fr = view.frame
            fr.origin.y += deltaY
            view.frame = fr
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            var offset: CGFloat = 0
            for colorView in self.colorViews.reversed() {
                guard !colorView.selected else { continue }
                var frame = colorView.frame
                frame.origin.y = offset
                colorView.frame = frame
                offset += self.itemSize + self.itemsPadding
            }
        }, completion: nil)
    }
    
    
    private func hideAllViews() {
        let deltaY = itemSize - self.bounds.height
        var frame = self.frame
        frame.origin.y -= deltaY
        frame.size.height = itemSize
        self.frame = frame
        for view in self.subviews {
            var fr = view.frame
            fr.origin.y += deltaY
            view.frame = fr
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            for view in self.subviews {
                var fr = view.frame
                fr.origin.y = 0
                view.frame = fr
            }
        }, completion: nil)
    }
}


private class ColorView: UIView {
    
    let index: Int
    var selected = false {
        didSet { updateSize() }
    }
    
    init(frame: CGRect, index: Int, hex: String) {
        self.index = index
        self.colorView = UIView(frame: frame)
        super.init(frame: frame)
        
        colorView.backgroundColor = UIColor.fromHex(hex)
        colorView.layer.borderColor = UIColor.white.cgColor
        self.addSubview(colorView)
        
        updateSize()
    }
    
    
    //MARK: - Private
    
    private let colorView: UIView
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updateSize() {
        let allSize: CGFloat = selected ? 46 : 28
        let offset = (self.bounds.size.width - allSize)/2
        colorView.layer.borderWidth = selected ? 5 : 3
        colorView.layer.cornerRadius = allSize/2
        colorView.frame = CGRect(x: offset, y: offset, width: allSize, height: allSize)
        
        
    }
}
