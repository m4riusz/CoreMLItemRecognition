//
//  ScreenCapturePresenter.swift
//  MLCoreItemRecognition
//
//  Created by Mariusz Sut on 03/11/2018.
//  Copyright © 2018 Mariusz Sut. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreML
import Vision

class ScreenCapturePresenter: NSObject, ScreenCapturePresenterProtocol {
    
    weak var view: ScreenCaptureViewProtocol?
    
    init(withView view: ScreenCaptureViewProtocol) {
        self.view = view
    }
    
    func checkPermission() {
        self.view?.onCameraPermissionChecking()
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.view?.onCameraPermissionGranted()
            self.view?.startScanning()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.view?.onCameraPermissionGranted()
                    self.view?.startScanning()
                } else {
                    self.view?.onCameraPermissionNotGranted()
                }
            })
        }
    }
    
    func openSettings() {
        guard let url = NSURL(string: UIApplication.openSettingsURLString) as URL? else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ScreenCapturePresenter: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            return
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard error == nil, let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                return
            }
            self.view?.onItemScanned(item: firstResult.identifier, probability: firstResult.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
