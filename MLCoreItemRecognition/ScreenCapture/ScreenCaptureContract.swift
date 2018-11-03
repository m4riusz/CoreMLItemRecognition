//
//  ScreenCaptureContract.swift
//  MLCoreItemRecognition
//
//  Created by Mariusz Sut on 03/11/2018.
//  Copyright © 2018 Mariusz Sut. All rights reserved.
//

import Foundation
import AVFoundation

protocol ScreenCaptureViewProtocol: NSObjectProtocol {
    func startScanning()
    func onItemScanned(item: String, probability: Float)
    func stopScanning()
    func onCameraPermissionChecking()
    func onCameraPermissionNotGranted()
    func onCameraPermissionGranted()
}

protocol ScreenCapturePresenterProtocol: NSObjectProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
    func checkPermission()
    func openSettings()
}
