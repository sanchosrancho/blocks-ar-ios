//
//  HUDViewController.swift
//  Modify
//
//  Created by Олег Адамов on 23.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


private class HUDButton: UIButton {}

class HUDWindow: UIWindow {
    
    var hudController: HUDViewController {
        return self.rootViewController as! HUDViewController
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = HUDViewController()
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        if hitView is HUDButton { return hitView }
        return nil
    }*/
}


@objc protocol HUDViewControllerDelegate: class {
    func hudAddObjectPressed(color: UIColor)
    func hudPlaceObjectPressed()
    func hudPlaceObjectCancelled()
    
    func hudPlaceChangeDistance(_ value: Float)
    func hudPlaceWillChangeDistance()
    
    func hudDidTap(_ gesture: UITapGestureRecognizer, color: UIColor)
    
    func hudDidChangeCurrentColor(_ color: UIColor)
    
    @objc optional func hudStopAdjustingNodesPosition()
    @objc optional func hudStartAdjustingNodesPosition()
}


class HUDViewController: UIViewController {

    weak var delegate: HUDViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecButton()
        setupAddButton()
        setupAdjustingNodePositionButton()
        setupPlaceButton()
        
        setupPan()
        setupTap()
        
        setupLocationStatus()
        setupColorPicker()
    }
    
    func updateLocationStatus(_ status: Application.LocationAccuracyState) {
        switch status {
        case .poor: locationStatus.text = "Bad location accuracy"
        case .good: locationStatus.text = "Good location accuracy"
        }
    }
    
    func cameraReady(_ ready: Bool) {
        self.addObjectButton.setTitleColor(ready ? .green : .lightGray, for: .normal)
    }
    
    
    func updateState(isPlacing: Bool) {
        addObjectButton.isSelected = isPlacing
        placeObjectButton.isHidden = !isPlacing
    }
    
    
    //MARK: - Private
    
    private let recButton = HUDButton(frame: CGRect(x: 20, y: 140, width: 60, height: 60))
    private let addObjectButton = HUDButton(frame: CGRect(x: 20, y: 30, width: 100, height: 44))
    private let toggleAdjustingNodePositionButton = HUDButton(frame: CGRect(x: 140, y: 30, width: 200, height: 44))
    private let placeObjectButton = HUDButton(frame: CGRect(x: round((UIScreen.main.bounds.width - 80)/2), y: UIScreen.main.bounds.height - 60, width: 80, height: 44))
    var startYPan: CGFloat = 0
    let locationStatus = UILabel(frame: CGRect(x: 20, y: 10, width: (UIScreen.main.bounds.width-40), height: 20))
    var colorPicker: ColorPickerView!
    
    
    private func setupLocationStatus() {
        locationStatus.layer.opacity = 0.6
        locationStatus.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        locationStatus.textColor = UIColor.white
        locationStatus.textAlignment = .center
        self.view.addSubview(locationStatus)
    }
    
    private func setupRecButton() {
        recButton.setImage(UIImage(named: "rec_start"), for: .normal)
        recButton.setImage(UIImage(named: "rec_stop"), for: .selected)
        recButton.addTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        self.view.addSubview(recButton)
    }
    
    
    private func setupAddButton() {
        addObjectButton.setTitle("Add object", for: .normal)
        addObjectButton.setTitle("Cancel", for: .selected)
        addObjectButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addObjectButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        self.view.addSubview(addObjectButton)
    }
    
    @objc private func addButtonPressed(_ sender: UIButton) {
        let color = self.colorPicker.currentColor
        sender.isSelected ? delegate?.hudPlaceObjectCancelled() : delegate?.hudAddObjectPressed(color: color)
    }
    
    private func setupAdjustingNodePositionButton() {
        toggleAdjustingNodePositionButton.setTitle("Stop adjusting", for: .normal)
        toggleAdjustingNodePositionButton.setTitle("Start adjusting", for: .selected)
        toggleAdjustingNodePositionButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        toggleAdjustingNodePositionButton.addTarget(self, action: #selector(toggleAdjustingNodePosition(sender:)), for: .touchUpInside)
        self.view.addSubview(toggleAdjustingNodePositionButton)
    }
    
    @objc private func toggleAdjustingNodePosition(sender: UIButton) {
        if sender.isSelected {
            self.delegate?.hudStartAdjustingNodesPosition?()
        } else {
            self.delegate?.hudStopAdjustingNodesPosition?()
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    private func setupPlaceButton() {
        placeObjectButton.setTitleColor(.white, for: .normal)
        placeObjectButton.setTitle("Place", for: .normal)
        placeObjectButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.7)
        placeObjectButton.addTarget(self, action: #selector(placeButtonPressed), for: .touchUpInside)
        placeObjectButton.isHidden = true
        self.view.addSubview(placeObjectButton)
    }
    
    @objc private func placeButtonPressed() {
        self.delegate?.hudPlaceObjectPressed()
    }
    
    
    private func setupColorPicker() {
        let pos = CGPoint(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height - 50)
        let colorPicker = ColorPickerView(position: pos)
        self.colorPicker = colorPicker
        self.colorPicker.delegate = self
        self.view.addSubview(colorPicker)
    }
}


extension HUDViewController: ColorPickerViewDelegate {
    
    func colorPickerDidUpdate(_ color: UIColor) {
        delegate?.hudDidChangeCurrentColor(color)
    }
}
