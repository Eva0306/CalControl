//
//  SceneDelegate.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var userProfileViewModel: UserProfileViewModel?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // 檢查是否有 userID
        if let userID = UserDefaults.standard.string(forKey: "userID") {
            // 有 userID，從 Firebase 獲取使用者資料並初始化 UserProfileViewModel
            fetchUser(userID: userID) { [weak self] user in
                guard let self = self else { return }
                
                // 初始化 UserProfileViewModel.shared
                UserProfileViewModel.shared = UserProfileViewModel(user: user)
                
                // 導航到主頁面
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // swiftlint:disable force_cast line_length
                let tabBarController = storyboard.instantiateInitialViewController() as! MainTabBarController
                // swiftlint:enable force_cast line_length
                
                // 設置主視圖
                self.window?.rootViewController = tabBarController
                self.window?.makeKeyAndVisible()
            }
        } else {
            // 沒有 userID，導航到填寫基本資料頁面
            //            let onboardingVC = OnboardingViewController() // 假設這是填寫基本資料的頁面，要記得將產生的 userID 儲存至 UserDefault
//            window?.rootViewController = UINavigationController(rootViewController: onboardingVC)
//            window?.makeKeyAndVisible()
        }
    }

    // 從 Firebase 獲取使用者資料
    private func fetchUser(userID: String, completion: @escaping (User) -> Void) {
        FirebaseManager.shared.getDocuments(from: .users, where: [("id", .isEqualTo, userID)]) { (users: [User]) in
            if let user = users.first {
                completion(user)
            } else {
                print("Error fetching user")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

