//
//  SceneDelegate.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var userProfileViewModel: UserProfileViewModel?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        testShowInfoVC()
        
//        if let currentUser = Auth.auth().currentUser {
//            print("User is already logged in: \(currentUser.uid)")
//            fetchUser(userID: currentUser.uid) { result in
//                switch result {
//                case .success(let user):
//                    self.showHomeScreen(for: user)
//                case .failure(let error):
//                    print("Error: \(error.localizedDescription)")
//                    self.showSingnInVC()
//                }
//            }
//        } else {
//            showSingnInVC()
//        }
    }
    
    private func testShowInfoVC() {
        let initialVC = DataCollectionContainerVC()
        window?.rootViewController = UINavigationController(rootViewController: initialVC)
        window?.makeKeyAndVisible()
    }
    
    private func showHomeScreen(for user: User) {
        UserProfileViewModel.shared = UserProfileViewModel(user: user)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable force_cast
        let tabBarController = storyboard.instantiateInitialViewController() as! MainTabBarController
        // swiftlint:enable force_cast
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
    }
    
    private func showSingnInVC() {
        let SignInVC = SignInVC()
        window?.rootViewController = UINavigationController(rootViewController: SignInVC)
        window?.makeKeyAndVisible()
    }
    
    private func fetchUser(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        let condition = [
            FirestoreCondition(field: "id", comparison: .isEqualTo, value: userID)]
        
        FirebaseManager.shared.getDocuments(from: .users, where: condition) { (users: [User]) in
            if let user = users.first {
                completion(.success(user))
            } else {
                let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                completion(.failure(error))
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

