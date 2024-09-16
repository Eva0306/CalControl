//
//  PhotosVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import PhotosUI

class PhotosVC: UIViewController, PHPickerViewControllerDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupPhotoPicker()
    }
    
    private func setupPhotoPicker() {
        // 創建配置
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
    
    // PHPickerViewControllerDelegate 方法，用來處理選擇的圖片
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // 處理選擇的結果
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

