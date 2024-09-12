//
//  CameraVC.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    
    var didTakenPhoto: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        setupOverlay()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // 選擇相機設備 (預設使用後攝像頭)
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Couldn't find the camera device")
            return
        }
        
        do {
            // 設定相機輸入
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // 設定相片輸出
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            captureSession.commitConfiguration()
            
            // 配置相機預覽層
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            // 啟動相機捕獲（放在背景執行緒）
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            
            // 添加拍照按鈕
            let captureButton = UIButton(frame: CGRect(x: (view.frame.size.width - 70) / 2, y: view.frame.size.height - 200, width: 70, height: 70))
            captureButton.backgroundColor = .white
            captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
            captureButton.layer.borderColor = UIColor.gray.cgColor
            captureButton.layer.borderWidth = 4
            captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
            view.addSubview(captureButton)
            
        } catch {
            print("Couldn't capture the photo: \(error)")
        }
    }
    
    @objc func capturePhoto() {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    
    private func setupOverlay() {
        let overlayView = UIView()
        
        // 設定 4:3 比例的框架大小
        let frameWidth: CGFloat = 300
        let frameHeight: CGFloat = frameWidth * 4 / 3
        
        overlayView.frame = CGRect(x: (view.frame.width - frameWidth) / 2,
                                   y: (view.frame.height - frameHeight) / 2 - 50,
                                   width: frameWidth,
                                   height: frameHeight)
        
        overlayView.layer.borderColor = UIColor.white.cgColor
        overlayView.layer.borderWidth = 2
        overlayView.layer.cornerRadius = 20
        
        overlayView.backgroundColor = UIColor.clear
        
        view.addSubview(overlayView)
    }
}

//MARK: - Photo Output
extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            print("Couldn't fetch the photo")
            return
        }
        
        goToCheckVC(with: image)
    }
    
    func goToCheckVC(with croppedImage: UIImage) {
        let checkVC = CheckVC()
        checkVC.checkPhoto = croppedImage
        checkVC.modalPresentationStyle = .fullScreen
        self.present(checkVC, animated: true, completion: nil)
    }
}
