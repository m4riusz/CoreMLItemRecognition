//
//  PermissionMaskView.swift
//  MLCoreItemRecognition
//
//  Created by Mariusz Sut on 03/11/2018.
//  Copyright © 2018 Mariusz Sut. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol PermissionMaskViewProtocol {
    func onSettingsButton()
}

class PermissionMaskView: UIView {
    static let defaultMargin: CGFloat = 10
    
    var state: ViewState = .pending { didSet { self.updateViewForState() }}
    var delegate: PermissionMaskViewProtocol?
    
    fileprivate var titleLabel: UILabel = UILabel()
    fileprivate var descriptionLabel: UILabel = UILabel()
    fileprivate var actionButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    fileprivate func initialize() {
        self.initTitleLabel()
        self.initDescriptionLabel()
        self.initActionButton()
    }
    
    fileprivate func initTitleLabel() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualToSuperview().offset(PermissionMaskView.defaultMargin)
            make.left.equalToSuperview().offset(PermissionMaskView.defaultMargin)
            make.right.equalToSuperview().offset(-PermissionMaskView.defaultMargin)
        }
    }
    
    fileprivate func initDescriptionLabel() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.numberOfLines = 0
        self.addSubview(self.descriptionLabel)
        
        self.descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(PermissionMaskView.defaultMargin)
            make.left.equalToSuperview().offset(PermissionMaskView.defaultMargin)
            make.right.equalToSuperview().offset(-PermissionMaskView.defaultMargin)
            make.centerY.equalToSuperview()
        }
    }
    
    fileprivate func initActionButton() {
        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.setTitleColor(UIColor.blue, for: .normal)
        self.addSubview(self.actionButton)
        self.actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(PermissionMaskView.defaultMargin)
            make.left.greaterThanOrEqualToSuperview().offset(PermissionMaskView.defaultMargin)
            make.right.greaterThanOrEqualToSuperview().offset(-PermissionMaskView.defaultMargin)
            make.bottom.greaterThanOrEqualToSuperview().offset(-PermissionMaskView.defaultMargin)
            make.centerX.equalToSuperview()
        }
    }
    
    fileprivate func updateViewForState() {
        var titleText: String = ""
        var descriptionText: String = ""
        var actionText: String = ""
        var actionEnabled: Bool = false
        var selector: Selector?
        var showView: Bool = true
        switch self.state {
        case .pending:
            titleText = "Checking..."
            descriptionText = "Checking camera permission."
            actionText = "In progress..."
            actionEnabled = false
            showView = true
        case .noPermission:
            titleText = "No permission"
            descriptionText = "Go to settings and enable camera permission."
            actionText = "Settings"
            actionEnabled = true
            selector = #selector(self.onActionNoPermission)
            showView = true
        case .none:
            showView = false
        }
        DispatchQueue.main.async {
            self.titleLabel.text = titleText
            self.descriptionLabel.text = descriptionText
            self.actionButton.setTitle(actionText, for: .normal)
            self.actionButton.isEnabled = actionEnabled
            self.actionButton.removeTarget(self, action: nil, for: .touchUpInside)
            if let sel = selector {
                self.actionButton.addTarget(self, action: sel, for: .touchUpInside)
            }
            self.isHidden = !showView
        }
    }
    
    @objc fileprivate func onActionNoPermission() {
        self.delegate?.onSettingsButton()
    }
    
    enum ViewState {
        case noPermission
        case pending
        case none
    }
}
