//
//  HUDViewController.swift
//  Modify
//
//  Created by Олег Адамов on 23.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


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
    var placeState = PlaceState.preview {
        didSet { updateStateAppearance() }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecButton()
        setupAddButton()
        setupCancelAddButton()
        setupEditModeView()
        
        setupPan()
        setupTap()
        
        setupLocationStatusLabel()
        setupColorPicker()
        
        updateStateAppearance()
        
        /* test */
        self.addObjectButton?.isHidden = true
    }
    
    
    func updateLocationStatus(_ status: Application.LocationAccuracyState) {
        switch status {
            case .poor: locationStatusLabel?.text = "Bad location accuracy"
            case .good: locationStatusLabel?.text = "Good location accuracy"
        }
    }
    
    
    func cameraReady(_ ready: Bool) {
        // self.addObjectButton.setTitleColor(ready ? .green : .lightGray, for: .normal)
    }
    
    
    private func updateStateAppearance() {
        switch placeState {
        case .preview:
            addObjectButton?.isSelected = false
            addObjectButton?.isHidden = false
            cancelAddButton?.isHidden = true
            colorPicker.isHidden = true
        case .placing(_):
            addObjectButton?.isSelected = true
            addObjectButton?.isHidden = false
            cancelAddButton?.isHidden = false
            colorPicker.isHidden = false
        case .editing(_):
            addObjectButton?.isHidden = true
            addObjectButton?.isSelected = false
            cancelAddButton?.isHidden = true
            colorPicker.isHidden = false
        }
    }
    
    
    //MARK: - Private
    
    var startYPan: CGFloat = 0
    var locationStatusLabel: UILabel?
    var addObjectButton: UIButton?
    var cancelAddButton: UIButton?
    var editModeView: EditModeView?
    var colorPicker: ColorPickerView!
    let bottomBaseYPosition: CGFloat = 54
    let baseXPadding: CGFloat = 15
    
    
    private func setupLocationStatusLabel() {
        let frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 20)
        let label = UILabel(frame: frame)
        label.layer.opacity = 0.6
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.view.addSubview(label)
        self.locationStatusLabel = label
    }
    
    
    private func setupRecButton() {
        /*
        recButton.setImage(UIImage(named: "rec_start"), for: .normal)
        recButton.setImage(UIImage(named: "rec_stop"), for: .selected)
        recButton.addTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        self.view.addSubview(recButton)
        */
    }
    
    
    private func setupAddButton() {
        let screenSize = UIScreen.main.bounds.size
        let size: CGFloat = 76
        let yPos = screenSize.height - bottomBaseYPosition - size/2
        
        let frame = CGRect(x: round((screenSize.width - size)/2), y: yPos, width: size, height: size)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "btn_add_obj"), for: .normal)
        button.setImage(UIImage(named: "btn_place_obj"), for: .selected)
        button.backgroundColor = .white
        button.tintColor = .innerGray
        button.layer.cornerRadius = size/2
        button.addTarget(self, action: #selector(addObjectButtonPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(button)
        self.addObjectButton = button
    }
    
    @objc private func addObjectButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            delegate?.hudPlaceObjectPressed()
        }
        else {
            delegate?.hudAddObjectPressed(color: colorPicker.currentColor)
        }
    }
    
    
    private func setupCancelAddButton() {
        let size: CGFloat = 46
        let yPos = UIScreen.main.bounds.size.height - bottomBaseYPosition - size/2
        
        let frame = CGRect(x: baseXPadding, y: yPos, width: size, height: size)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "btn_cancel_add"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .innerGray
        button.layer.cornerRadius = size/2
        button.addTarget(self, action: #selector(cancelAddButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(button)
        self.cancelAddButton = button
    }
    
    @objc private func cancelAddButtonPressed() {
        delegate?.hudPlaceObjectCancelled()
    }
    
    /*
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
    */
    
    /*
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
    */
    
    private func setupColorPicker() {
        let xPos = UIScreen.main.bounds.width - baseXPadding - round(ColorPickerView.itemSize/2)
        let pos = CGPoint(x: xPos, y: UIScreen.main.bounds.height - bottomBaseYPosition)
        let colorPicker = ColorPickerView(position: pos)
        self.colorPicker = colorPicker
        self.colorPicker.delegate = self
        self.view.addSubview(colorPicker)
    }
    
    
    private func setupEditModeView() {
        let screenSize = UIScreen.main.bounds.size
        let position = CGPoint(x: round(screenSize.width/2), y: screenSize.height - bottomBaseYPosition)
        let editView = EditModeView(position: position)
        self.view.addSubview(editView)
        self.editModeView = editView
    }
}


extension HUDViewController: ColorPickerViewDelegate {
    
    func colorPickerDidUpdate(_ color: UIColor) {
        delegate?.hudDidChangeCurrentColor(color)
    }
}
