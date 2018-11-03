//
//  ViewController.swift
//  MLCoreItemRecognition
//
//  Created by Mariusz Sut on 03/11/2018.
//  Copyright © 2018 Mariusz Sut. All rights reserved.
//

import UIKit
import AVFoundation

class ScreenCaptureController: UIViewController {
    static let defaultMargin: CGFloat = 10
    
    fileprivate var presenter: ScreenCapturePresenterProtocol?
    fileprivate var maskView: PermissionMaskView?
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var descriptionLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initDescriptionLabel()
        self.initPresenter()
        self.initPermissionMask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.checkPermission()
    }
    
    fileprivate func initDescriptionLabel() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.textColor = UIColor.blue
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.numberOfLines = 0
        self.view.addSubview(self.descriptionLabel)
        
        self.descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(ScreenCaptureController.defaultMargin)
            make.right.equalToSuperview().offset(-ScreenCaptureController.defaultMargin)
            make.bottom.equalToSuperview().offset(-ScreenCaptureController.defaultMargin)
        }
    }
    
    fileprivate func initPresenter() {
        self.presenter = ScreenCapturePresenter(withView: self)
    }

    fileprivate func initPermissionMask() {
        self.maskView = PermissionMaskView()
        self.maskView?.delegate = self
        self.view.addSubview(self.maskView!)
        
        self.maskView?.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        })
    }
}

extension ScreenCaptureController: ScreenCaptureViewProtocol {
    func startScanning() {
        guard self.captureSession == nil else {
            self.captureSession?.startRunning()
            return
        }
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = .photo
        guard let cameraInput = try?  AVCaptureDeviceInput(device: device) else {
            return
        }
        self.captureSession?.addInput(cameraInput)
        self.captureSession?.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.frame
        
        let cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.setSampleBufferDelegate(self.presenter!, queue: DispatchQueue(label: "CameraOutputBuffer"))
        self.captureSession?.addOutput(cameraOutput)
    }
    
    func onItemScanned(item: String, probability: Float) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = probability > 0.5 ? "\(item)\n\(probability)" : ""
        }
    }
    
    func stopScanning() {
        self.captureSession?.stopRunning()
    }
    
    func onCameraPermissionChecking() {
        self.maskView?.state = .pending
    }
    
    func onCameraPermissionNotGranted() {
        self.maskView?.state = .noPermission
    }
    
    func onCameraPermissionGranted() {
        self.maskView?.state = .none
    }
}

extension ScreenCaptureController: PermissionMaskViewProtocol {
    func onSettingsButton() {
        self.presenter?.openSettings()
    }
}
