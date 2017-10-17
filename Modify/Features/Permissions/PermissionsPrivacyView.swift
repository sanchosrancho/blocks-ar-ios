//
//  PermissionsPrivacyView.swift
//  Modify
//
//  Created by Олег Адамов on 17.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit

class PermissionsPrivacyView: UIView {

    weak var delegate: PermissionViewProtocol?
    var permissionType: PermissionType
    
    
    init(frame: CGRect, type: PermissionType) {
        self.permissionType = type
        super.init(frame: frame)
        
        setupActionButton()
    }
    
    
    //MARK: - Private
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupActionButton() {
        let frame = CGRect(x: round((self.bounds.width - 240)/2), y: self.bounds.height - 60 - 50, width: 240, height: 50)
        let button = UIButton(frame: frame)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.fromRGB(r: 183, g: 230, b: 132)
        button.setAttributedTitle(attributedTitleForActionButton(), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        self.addSubview(button)
    }
    
    @objc private func actionButtonPressed() {
        self.delegate?.actionButtonPressed(with: self.permissionType)
    }
    
    
    private func attributedTitleForActionButton() -> NSAttributedString {
        let text = "allow_key".localized
        return NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7),
                                                             .font: UIFont.systemFont(ofSize: 18, weight: .medium) ])
    }
}
