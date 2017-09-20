//
//  HUDViewController+Recording.swift
//  Modify
//
//  Created by Олег Адамов on 18.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit
import ReplayKit


extension HUDViewController {
    
    @objc func startRecording(sender: UIButton) {
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
    
    
    @objc func stopRecording(sender: UIButton) {
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
                sender.addTarget(self, action: #selector(self.startRecording(sender:)), for: .touchUpInside)
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
}


extension HUDViewController: RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
