//
//  HUDViewController.swift
//  Modify
//
//  Created by Олег Адамов on 23.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit
import ReplayKit


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
    func hudAddObjectPressed()
    func hudPlaceObjectPressed()
    func hudPlaceObjectCancelled()
    
    func hudPlaceChangeDistance(_ value: Float)
    func hudPlaceWillChangeDistance()
    
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
    private let addObjectButton = HUDButton(frame: CGRect(x: 20, y: 20, width: 100, height: 44))
    private let toggleAdjustingNodePositionButton = HUDButton(frame: CGRect(x: 140, y: 20, width: 200, height: 44))
    private let placeObjectButton = HUDButton(frame: CGRect(x: round((UIScreen.main.bounds.width - 80)/2), y: UIScreen.main.bounds.height - 60, width: 80, height: 44))
    private var startYPos: CGFloat = 0
    
    
    private func setupRecButton() {
        recButton.setImage(UIImage(named: "rec_start"), for: .normal)
        recButton.setImage(UIImage(named: "rec_stop"), for: .selected)
        recButton.addTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        self.view.addSubview(recButton)
    }
    
    @objc private func startRecording(sender: UIButton) {
        guard !sender.isSelected else {
            print("Already recording!")
            return
        }
        
        guard RPScreenRecorder.shared().isAvailable else {
            print("Error: screen record not available")
            return
        }
        
        sender.removeTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error start recording: \(error!)")
                    return
                }
                print("Did start recording...")
                sender.addTarget(self, action: #selector(self.stopRecording(sender:)), for: .touchUpInside)
                sender.isSelected = true
            }
        }
    }
    
    
    @objc private func stopRecording(sender: UIButton) {
        guard sender.isSelected else {
            print("Not in recording!")
            return
        }
        
        sender.removeTarget(self, action: #selector(stopRecording(sender:)), for: .touchUpInside)
        RPScreenRecorder.shared().stopRecording { previewController, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error stop recording: \(error!)")
                    return
                }
                print("Did stop recording...")
                sender.addTarget(self, action: #selector(self.stopRecording(sender:)), for: .touchUpInside)
                sender.isSelected = false
                
                guard let preview = previewController else {
                    print("No preview controller")
                    return
                }
                preview.previewControllerDelegate = self
                self.present(preview, animated: true, completion: nil)
            }
        }
    }
    
    
    private func setupAddButton() {
        addObjectButton.setTitle("Add object", for: .normal)
        addObjectButton.setTitle("Cancel", for: .selected)
        addObjectButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addObjectButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        self.view.addSubview(addObjectButton)
    }
    
    @objc private func addButtonPressed(_ sender: UIButton) {
        sender.isSelected ? delegate?.hudPlaceObjectCancelled() : delegate?.hudAddObjectPressed()
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
    
    
    private func setupPan() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.view)
        switch gesture.state {
        case .began:
            self.startYPos = location.y
            self.delegate?.hudPlaceWillChangeDistance()
        case .changed:
            var deltaY = (location.y - startYPos)/12
            deltaY = CGFloat(round(100 * deltaY) / 100)
            self.delegate?.hudPlaceChangeDistance(Float(deltaY))
        case .ended: break
        default: break
        }
    }
}


extension HUDViewController: RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
