//
//  ScanQRCodeVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit
import AVFoundation

class ScanQRCodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var viewModel: FriendViewModel?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    lazy var slashImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "video.slash")
        iv.tintColor = UIColor.mainGreen.withAlphaComponent(0.6)
        iv.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        iv.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubview(slashImage)
        
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession == nil {
            setupCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
            self.captureSession = nil
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            debugLog("Failed to access camera")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                debugLog("Failed to add video input to session")
                return
            }
        } catch {
            debugLog("Error setting up video input - \(error)")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            debugLog("Failed to add metadata output to session")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        let cameraHeight: CGFloat = view.frame.height * 0.6
        previewLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: cameraHeight)
        
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    // MARK: - QR Code Detection
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // 播放震動提示
            showAddFriendAlert(friendID: stringValue)
        }
    }
    
    // MARK: - Show Alert
    private func showAddFriendAlert(friendID: String) {
        let alertController = UIAlertController(
            title: "添加好友",
            message: "是否要添加此ID為好友：\(friendID)",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            self?.addFriend(with: friendID)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.captureSession.startRunning()
            }
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Add Friend
    private func addFriend(with friendID: String) {
        self.viewModel?.addFriend(self, with: friendID)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}
