//
//  SceneDelegate.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import FirebaseAuth
import Lottie

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var userProfileViewModel: UserProfileViewModel?
    private var lottieAnimationView: LottieAnimationView?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        testShowInfoVC()
//        let loadingVC = UIViewController()
//        loadingVC.view.backgroundColor = .background
//        window?.rootViewController = loadingVC
//        window?.makeKeyAndVisible()
//        
//        let loadingView = LoadingView()
//        loadingView.show(in: loadingVC.view, withBackground: false)
//        
//        if let currentUser = Auth.auth().currentUser {
//            debugLog("User is already logged in: \(currentUser.uid)")
//            
//            fetchUser(userID: currentUser.uid) { result in
//                DispatchQueue.main.async {
//                    
//                    loadingView.hide()
//                    
//                    switch result {
//                    case .success(let user):
//                        self.showHomeScreen(for: user)
//                    case .failure(let error):
//                        debugLog("Error - \(error.localizedDescription)")
//                        self.showSignInVC()
//                    }
//                }
//            }
//        } else {
//            debugLog("No user logged in, showing sign-in screen.")
//            showSignInVC()
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
        guard let tabBarController = storyboard.instantiateInitialViewController() as?
                MainTabBarController else {
            fatalError("Unable to instantiate MainTabBarController from storyboard.")
        }
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
    }
    
    private func showSignInVC() {
        let signInVC = SignInVC()
        window?.rootViewController = UINavigationController(rootViewController: signInVC)
        window?.makeKeyAndVisible()
    }
    
    private func fetchUser(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        let condition = [
            FirestoreCondition(field: "id", comparison: .isEqualTo, value: userID)]
        
        FirebaseManager.shared.getDocuments(
            from: .users, where: condition
        ) { (users: [User]) in
            if let user = users.first {
                debugLog("User found")
                completion(.success(user))
            } else {
                let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                debugLog("ERROR - User not found for ID: \(userID)")
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
