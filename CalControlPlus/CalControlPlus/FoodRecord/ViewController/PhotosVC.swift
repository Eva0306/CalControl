//
//  PhotosVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import PhotosUI
import Photos

class PhotosVC: UIViewController, PHPickerViewControllerDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupPhotoPicker()
    }
    
    private func setupPhotoPicker() {
        // 檢查照片庫權限
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    // 用戶授權完全訪問
                    self?.presentPhotoPicker()
                    
                case .limited:
                    // 用戶只授權有限的照片訪問，提示用戶可以選擇更多的照片
                    self?.presentLimitedAccessAlert()
                    
                case .denied, .restricted:
                    // 用戶拒絕授權，可能需要提示用戶去設置授權
                    self?.presentDeniedAccessAlert()
                    
                default:
                    break
                }
            }
        }
    }
    
    private func presentPhotoPicker() {
        // 創建 PHPicker 的配置
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        // 創建 PHPickerViewController
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // 添加 PHPickerViewController 作為子控制器
        addChild(picker)
        view.addSubview(picker.view)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置約束，使其嵌入到當前視圖控制器中
        if let tabBarHeight = tabBarController?.tabBar.frame.height {
            NSLayoutConstraint.activate([
                picker.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                picker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                picker.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                picker.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight)
            ])
        }
        
        picker.didMove(toParent: self) // 通知子控制器已添加完成
    }
    
    private func presentLimitedAccessAlert() {
        let alert = UIAlertController(
            title: "有限照片訪問",
            message: "你目前僅限訪問部分照片。要選擇更多的照片或相簿，請更新訪問權限。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "選擇更多照片", style: .default, handler: { _ in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentDeniedAccessAlert() {
        let alert = UIAlertController(
            title: "無法訪問照片",
            message: "應用無法訪問你的照片。請到「設置」中啟用照片訪問權限。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "打開設置", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // PHPickerViewController Delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.isEmpty {
            self.tabBarController?.dismiss(animated: true, completion: nil)
        } else {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.goToCheckVC(with: image)
                        }
                    }
                }
            }
        }
    }
    
    func goToCheckVC(with image: UIImage) {
        let checkVC = CheckVC()
        checkVC.checkPhoto = image
        if let recordTabBarController = self.tabBarController as? RecordTabBarController {
            checkVC.mealType = recordTabBarController.selectedMealType
        } else {
            debugLog("Tab bar controller is not of type RecordTabBarController")
        }
        checkVC.modalPresentationStyle = .fullScreen
        self.present(checkVC, animated: true, completion: nil)
    }
}
