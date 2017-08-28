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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        if hitView is HUDButton { return hitView }
        return nil
    }
}

@objc  protocol HUDViewControllerDelegate: class {
    func hudAddObjectPressed()
    @objc optional func hudStopAdjustingNodesPosition()
    @objc optional func hudStartAdjustingNodesPosition()
}

class HUDViewController: UIViewController {

    weak var delegate: HUDViewControllerDelegate?
    
    private let recButton = HUDButton(frame: CGRect(x: 20, y: 140, width: 60, height: 60))
    private let addObjectButton = HUDButton(frame: CGRect(x: 20, y: 20, width: 100, height: 44))
    private let toggleAdjustingNodePositionButton = HUDButton(frame: CGRect(x: 140, y: 20, width: 200, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecButton()
        setupAddButton()
        setupAdjustingNodePositionButton()
    }
    
    
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
    
    
    func setupAddButton() {
        addObjectButton.setTitle("Add object", for: .normal)
        addObjectButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addObjectButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        self.view.addSubview(addObjectButton)
    }
    
    @objc private func addButtonPressed() {
        self.delegate?.hudAddObjectPressed()
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
}


extension HUDViewController: RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
