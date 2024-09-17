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
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.imageView?.contentMode = .scaleToFill
        btn.tintColor = .white
        btn.contentMode = .scaleToFill
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupCamera()
        setupButton()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // 選擇相機設備 (預設使用後攝像頭)
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            
            print("Couldn't find the camera device")
            
            let slashImage = UIImageView(image: UIImage(systemName: "video.slash"))
            slashImage.tintColor = UIColor.mainGreen.withAlphaComponent(0.6)
            slashImage.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            slashImage.center = view.center
            view.addSubview(slashImage)
            
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
            setupCameraItems()
            
        } catch {
            print("Couldn't capture the photo: \(error)")
        }
    }
    
    @objc func capturePhoto() {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    
    private func setupCameraItems() {
        let overlayView = UIView()
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
        
        let captureButton = UIButton()
        captureButton.frame = CGRect(x: (view.frame.size.width - 70) / 2,
                                     y: view.frame.size.height - 180,
                                     width: 70,
                                     height: 70)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
        captureButton.layer.borderColor = UIColor.gray.cgColor
        captureButton.layer.borderWidth = 4
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    private func setupButton() {
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func closeVC() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Photo Output
extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            print("Couldn't fetch the photo")
            return
        }
        
        goToCheckVC(with: image)
    }
    
    func goToCheckVC(with image: UIImage) {
        let checkVC = CheckVC()
        checkVC.checkPhoto = image
        if let recordTabBarController = self.tabBarController as? RecordTabBarController {
            checkVC.mealType = recordTabBarController.selectedMealType
        } else {
            print("Tab bar controller is not of type RecordTabBarController")
        }
        checkVC.modalPresentationStyle = .fullScreen
        self.present(checkVC, animated: true, completion: nil)
    }
}
